//
//  ObservableProxy.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "NSObject+Observable.h"
#import "Kensho.h"
#import "objc/runtime.h"
#import "KenObservationTracking.h"


static const void *ObservableInstanceHelperKey = &ObservableInstanceHelperKey;
static const void *ObservableClassHelperKey = &ObservableClassHelperKey;

@implementation NSObject (Observable)

#pragma mark - Internal Implementation

- (id) observe:(Kensho*)ken
{
    NSSet* allAttributes = [[self class] makeClassObservable];
    
    KenObservationTracking* strongTracker = objc_getAssociatedObject(self, ObservableInstanceHelperKey);
    if(strongTracker == nil)
    {
        strongTracker = [[KenObservationTracking alloc] initWithTarget:self kensho:ken attributes:allAttributes];
        objc_setAssociatedObject(self, ObservableInstanceHelperKey, strongTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    for(NSString* attribute in allAttributes)
    {
        // evaluate once to determine what to track for dependencies
        [self performSelector:NSSelectorFromString(attribute)];
    }
    
    return self;
}

#pragma mark - IObservable

- (void) addObserver:(NSObject<IObserver>*)observer attribute:(NSString*)selfAttribute context:(NSString*)context
{
    // We delegate this to our tracking object
    KenObservationTracking* tracker = objc_getAssociatedObject(self, ObservableInstanceHelperKey);
    [tracker addObserver:observer attribute:selfAttribute context:context];
}

- (void) removeObserver:(NSObject<IObserver>*)existingObserver attribute:(NSString*)selfAttribute context:(NSString*)existingContext
{
    KenObservationTracking* tracker = objc_getAssociatedObject(self, ObservableInstanceHelperKey);
    [tracker removeObserver:existingObserver attribute:selfAttribute context:existingContext];
}

#pragma mark - Class swizzling

#define WRAP_ACCESS(TYPE, PROPERTYNAME) \
    imp_implementationWithBlock(^(id _s) {  \
    KenObservationTracking* tracker = objc_getAssociatedObject(_s, ObservableInstanceHelperKey);   \
    [tracker startTrackingAttribute:propertyName];  \
    TYPE result = ((TYPE(*)(id,SEL))originalMethod)(_s, NSSelectorFromString(propertyName));    \
    [tracker endTrackingAttribute:propertyName];    \
    return result;  \
    });


+ (NSSet*) makeClassObservable
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
                    skewIMP = WRAP_ACCESS(char, propertyName);
                }
                 /*i
                 An int*/
                case 'i':
                {
                    skewIMP = WRAP_ACCESS(int, propertyName);
                    break;
                }
                 /*s
                 A short*/
                case 's':
                {
                    skewIMP = WRAP_ACCESS(short, propertyName);
                    break;
                }
                 /*l
                 A long
                 l is treated as a 32-bit quantity on 64-bit programs.*/
                case 'l':
                {
                    skewIMP = WRAP_ACCESS(long, propertyName);
                break;
                }
                 /*q
                 A long long*/
                case 'q':
                {
                    skewIMP = WRAP_ACCESS(long long, propertyName);
                    break;
                }
                 /*C
                 An unsigned char*/
                case 'C':
                {
                    skewIMP = WRAP_ACCESS(unsigned char, propertyName);
                    break;
                }
                 /*I
                 An unsigned int*/
                case 'I':
                {
                    skewIMP = WRAP_ACCESS(unsigned int, propertyName);
                    break;
                }
                 /*S
                 An unsigned short*/
                    case 'S':
                {
                    skewIMP = WRAP_ACCESS(unsigned short, propertyName);
                    break;
                }
                 /*L
                 An unsigned long*/
                case 'L':
                {
                    skewIMP = WRAP_ACCESS(unsigned long, propertyName);
                    break;
                }
                 /*Q
                 An unsigned long long*/
                case 'Q':
                {
                    skewIMP = WRAP_ACCESS(unsigned long long, propertyName);
                    break;
                }
                 /*f
                  A float*/
                case 'f':
                {
                    skewIMP = WRAP_ACCESS(float, propertyName);
                    break;
                }
                 /*d
                  A double*/
                case 'd':
                {
                    skewIMP = WRAP_ACCESS(double, propertyName);
                    break;
                }
                 /*B
                 A C++ bool or a C99 _Bool*/
                case 'B':
                {
                    skewIMP = WRAP_ACCESS(bool, propertyName);
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
                    skewIMP = WRAP_ACCESS(char*, propertyName);
                    break;
                }
                 /*@
                 An object (whether statically typed or typed id)*/
                case '@':
                {
                    skewIMP = WRAP_ACCESS(id, propertyName);
                    break;
                }
                 /*#
                 A class object (Class)*/
                case '#':
                {
                    skewIMP = WRAP_ACCESS(Class, propertyName);
                    break;
                }
                 /*:
                 A method selector (SEL)*/
                case ':':
                {
                    skewIMP = WRAP_ACCESS(SEL, propertyName);
                    break;
                }
                default:
                    continue;
            }
            // This sets it at the CLASS level, not the instance!!!!!!!
            originalMethod = method_setImplementation(m, (IMP)skewIMP);
        }
        
        if([self superclass] != nil && [self superclass] != NSObject.class)
        {
            [attributeSet addObjectsFromArray:[[[self superclass] makeClassObservable] allObjects]];
        }
        
        objc_setAssociatedObject(self, ObservableClassHelperKey, attributeSet, OBJC_ASSOCIATION_RETAIN);
        
    }
    return attributeSet;
}

@end
