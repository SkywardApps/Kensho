//
//  ObservableProxy.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableProxy.h"
#import "Kensho.h"
#import "objc/runtime.h"
#import "WeakProxy.h"

@interface ObservableProxyTracking : NSObject
{
    NSMutableDictionary* observingMap;
    NSMutableDictionary* attributeMap;
    __weak Kensho* ken;
    __weak id target;
}

- (id) initWithTarget:(id)initialTarget kensho:(Kensho*)initialKen;
- (void) startTrackingAttribute:(NSString*)selfAttribute;
- (void) endTrackingAttribute:(NSString*)selfAttribute;

@end

@implementation ObservableProxyTracking

- (id) initWithTarget:(id)initialTarget kensho:(Kensho*)initialKen
{
    if((self = [super init]))
    {
        ken = initialKen;
        target = initialTarget;
        attributeMap = [NSMutableDictionary dictionary];
        observingMap = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void) startTrackingAttribute:(NSString*)selfAttribute
{
    // Clear all dependencies for this attribute
    for(NSArray* elements in attributeMap[selfAttribute])
    {
        NSObject* targetObject = [elements[0] strong];
        NSString* targetAttribute = elements[1];
        if(targetObject == nil)
        {
            continue;
        }
        
        NSNumber* key = [NSNumber numberWithUnsignedLongLong:(unsigned long long)targetObject];
        
        // Remove this attribute from the list of dependancies
        [observingMap[targetAttribute][key] removeObject:selfAttribute];
        
        // If this was the last dependency for this object-attribute, de-observe it
        if([observingMap[targetAttribute][key] count] == 0)
        {
            [targetObject removeObserver:self forKeyPath:targetAttribute];
        }
    }
    
    [attributeMap[selfAttribute] removeAllObjects];
    [ken startTrackingDirectAccess];
}

- (void) endTrackingAttribute:(NSString*)selfAttribute
{
    NSDictionary* newlyObserved = [ken endTrackingDirectAccess];
    
    if(attributeMap[selfAttribute] == nil)
    {
        attributeMap[selfAttribute] = [NSMutableArray array];
    }
    
    // Reference anything we accessed
    for(NSString* targetAttribute in newlyObserved.allKeys)
    {
        for(NSObject* targetObject in newlyObserved[targetAttribute])
        {
            NSNumber* key = [NSNumber numberWithUnsignedLongLong:(unsigned long long)targetObject];
            if(observingMap[targetAttribute] == nil)
            {
                observingMap[targetAttribute] = [NSMutableDictionary dictionary];
            }
            if(observingMap[targetAttribute][key] == nil)
            {
                observingMap[targetAttribute][key] = [NSMutableSet set];
            }
            
            if([observingMap[targetAttribute][key] count] == 0)
            {
                [targetObject addObserver:self forKeyPath:targetAttribute options:NSKeyValueObservingOptionNew context:nil];
            }
            
            [observingMap[targetAttribute][key] addObject:selfAttribute];
            [attributeMap[selfAttribute] addObject:@[targetObject.unsafe, targetAttribute]];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber* key = [NSNumber numberWithUnsignedLongLong:(unsigned long long)object];
    //This will have to trigger an update to KVO
    for(NSString* selfAttribute in observingMap[keyPath][key])
    {
        [target willChangeValueForKey:selfAttribute];
    }
    
    // Imply changes here?
    
    for(NSString* selfAttribute in [(NSArray*)[(NSSet*)observingMap[keyPath][key] allObjects] reverseObjectEnumerator])
    {
        [target didChangeValueForKey:selfAttribute];
    }
}

- (void)unobserve
{
    // Clear all dependencies for all attributes
    for(NSString* selfAttribute in attributeMap.allKeys)
    {
        for(NSArray* elements in attributeMap[selfAttribute])
        {
            NSObject* targetObject = elements[0];
            NSString* targetAttribute = elements[1];
            if(targetObject == nil)
            {
                continue;
            }
            
            if(targetObject)
            {
                NSNumber* key = [NSNumber numberWithLongLong:(long long)targetObject];
                
                // Remove this attribute from the list of dependancies
                [observingMap[targetAttribute][key] removeObject:selfAttribute];
                
                // If this was the last dependency for this object-attribute, de-observe it
                if([observingMap[targetAttribute][key] count] == 0)
                {
                    [targetObject removeObserver:self forKeyPath:targetAttribute];
                }
            }
        }
    }
    attributeMap = nil;
    observingMap = nil;
}


- (void)dealloc
{
    [self unobserve];
}



@end


static const void *ObservableProxyHelperKey = &ObservableProxyHelperKey;
static const void *ObservableClassHelperKey = &ObservableClassHelperKey;

@implementation NSObject (Observable)

- (id) observableBy:(Kensho*)ken
{
    ObservableProxyTracking* strongTracker = objc_getAssociatedObject(self, ObservableProxyHelperKey);
    if(strongTracker == nil)
    {
        strongTracker = [[ObservableProxyTracking alloc] initWithTarget:self kensho:ken];
        objc_setAssociatedObject(self, ObservableProxyHelperKey, strongTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSSet* allAttributes = [[self class] makeClassObservableWithKensho:ken];
    for(NSString* attribute in allAttributes)
    {
        // evaluate once to determine what to track for dependencies
        [self performSelector:NSSelectorFromString(attribute)];
    }
    
    return self;
}

+ (NSSet*) makeClassObservableWithKensho:(Kensho*)ken
{
    NSMutableSet* attributeSet = objc_getAssociatedObject(self, ObservableClassHelperKey);
    if(attributeSet == nil)
    {
        // Loop through and find all assignable properties
        // swizzle them
        attributeSet = [NSMutableSet set];
        unsigned int propertyCount = 0;
        objc_property_t* propertyList = class_copyPropertyList([self class], &propertyCount);
        for(int i = 0; i < propertyCount; ++i)
        {
            // turn this into a property selector
            NSString* propertyName = [NSString stringWithUTF8String:property_getName(propertyList[i])];
            [attributeSet addObject:propertyName];
            
            Method m = class_getInstanceMethod([self class],  NSSelectorFromString(propertyName));
            char type[128];
            method_getReturnType(m, type, sizeof(type));
            
            __block IMP originalMethod;
            IMP skewIMP;
            switch(type[0])
            {
                /**
                 c
                 A char
                 */
                case 'c':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        char result = ((char(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*i
                 An int*/
                case 'i':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        int result = ((int(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*s
                 A short*/
                    case 's':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        short result = ((short(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*l
                 A long
                 l is treated as a 32-bit quantity on 64-bit programs.*/
                    case 'l':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        long result = ((long(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*q
                 A long long*/
                    case 'q':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        long long result = ((long long(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*C
                 An unsigned char*/
                    case 'C':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        unsigned char result = ((unsigned char(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*I
                 An unsigned int*/
                case 'I':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        unsigned int result = ((unsigned int(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*S
                 An unsigned short*/
                    case 'S':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        unsigned short result = ((unsigned short(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*L
                 An unsigned long*/
                case 'L':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        unsigned long result = ((unsigned long(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*Q
                 An unsigned long long*/
                case 'Q':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        unsigned long long result = ((unsigned long long(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*f
                  A float*/
                    case 'f':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        float result = ((float(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*d
                  A double*/
                    case 'd':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        double result = ((double(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*B
                 A C++ bool or a C99 _Bool*/
                 case 'B':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        bool result = ((bool(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*v
                 A void*/
                    case 'v':
                    
                {
                    continue;
                }
                 /**
                 A character string (char *)*/
                case '*':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        char* result = ((char*(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*@
                 An object (whether statically typed or typed id)*/
                case '@':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        id result = ((id(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*#
                 A class object (Class)*/
                case '#':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        Class result = ((Class(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                 /*:
                 A method selector (SEL)*/
                case ':':
                {
                    skewIMP = imp_implementationWithBlock(^(id _s) {
                        ObservableProxyTracking* tracker = objc_getAssociatedObject(_s, ObservableProxyHelperKey);
                        [ken key:propertyName accessedOn:_s];
                        [tracker startTrackingAttribute:propertyName];
                        SEL result = ((SEL(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));
                        [tracker endTrackingAttribute:propertyName];
                        return result;
                    });
                    break;
                }
                default:
                    continue;
            }
            // This sets it at the CLASS level, not the instance!!!!!!!
            originalMethod = method_setImplementation(m, (IMP)skewIMP);
        }
        
        objc_setAssociatedObject(self, ObservableClassHelperKey, attributeSet, OBJC_ASSOCIATION_RETAIN);
        
        //Method d0 = class_getClassMethod([self class], NSSelectorFromString(@"dealloc"));
        //Method d1 = class_getClassMethod([self class], @selector(priorDealloc));
        
        //IMP id1 = method_getImplementation(d1);
        //method_setImplementation(d0, id1);
        
       // method_exchangeImplementations(d0, d1);
        
    }
    return attributeSet;
}

@end
