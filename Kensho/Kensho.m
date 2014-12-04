//
//  Kensho.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Kensho.h"
#import "Bindings/Interfaces/Binding.h"
#import "Utilities/UIView+Kensho.h"
#import "KenshoContext.h"
#import "KenshoLuaWrapper.h"
#import "KenComputed.h"
#import <objc/runtime.h>
#import "WeakProxy.h"


typedef NSObject<Binding>* (^bindingFactoryMethod)(UIView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context);

@interface Kensho ()
{
    NSMutableArray* trackings;
    NSMutableDictionary* assignedBindings;
}

@end

@implementation Kensho

- (void) startTracking
{
    [trackings addObject:[NSMutableSet set]];
}

- (void) observableAccessed:(NSObject<IObservable>*)observable
{
    NSMutableSet* set = trackings.lastObject;
    [set addObject:observable];
}

- (void) key:(NSString*)key accessedOn:(NSObject*)target
{
    [trackings.lastObject addObject:@[target.weak, key]];
}

- (NSMutableSet*) endTracking
{
    NSMutableSet* set = trackings.lastObject;
    [trackings removeLastObject];
    return set;
}


- (id) init
{
    if((self = [super init]))
    {
        //_errorMessage = [[Observable alloc] initWithKensho:self];
        
        _bindingFactories = [NSMutableDictionary dictionary];
        
        int classCount = 0;
        Class* classList = NULL;
        
        classCount = objc_getClassList(classList, 0);
        classList = (Class*)malloc(sizeof(Class) * classCount);
        objc_getClassList(classList, classCount);
        
        for(int i = 0; i < classCount; ++i)
        {
            Class specificClass = classList[i];
            Class class = specificClass;
            while(class != nil)
            {
                if(class_getClassMethod(class, @selector(registerFactoriesTo:)))
                {
                    [class registerFactoriesTo:self];
                }
                
                Class superClass = class_getSuperclass(class);
                class = superClass;
            }
        }
        
        free(classList);
        
        trackings = [NSMutableArray array];
        assignedBindings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) applyBindings:(UIView*)rootView viewModel:(NSObject*)model
{
    KenshoContext* rootContext = [[KenshoContext alloc] initWithContext:model parent:nil];
    [self bindToView:rootView context:rootContext];
}

- (void) bindToView:(UIView *)view context:(KenshoContext*)initialContext
{
    KenshoContext* context = initialContext;
    
    // verify the format  ..... label: .....
    if(view.ken.allKeys.count > 0)
    {
        for(NSString* bindType in view.ken.allKeys)
        {
            NSString* bindValue = view.ken[bindType];
            
            KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:self context:context code:bindValue];
            
            // Register this binding against this view
            NSString* viewKey = [NSString stringWithFormat:@"%p", view];
            if(assignedBindings[viewKey] == nil)
            {
                assignedBindings[viewKey] = [NSMutableSet set];
            }
            [assignedBindings[viewKey] addObject:wrapper];
            
            
            // Handle the special-case structural bindings
            if([bindValue isEqualToString:@"with"])
            {
                // We will need to change the context from now on
                // This is an observable... so \todo rebind if this changes
               // context = [[KenshoContext alloc] initWithContext:targetValue.value parent:context];
                continue;
            }
            
            NSObject<Binding>* binding = nil;
            
            // iterate through classes and their parents
            Class viewClass = nil;
            while((viewClass = (viewClass == nil ? view.class : [viewClass superclass])))
            {
                // We dispatch based on the view type and the binding type here
                if(_bindingFactories[viewClass] == nil)
                {
                    continue;
                }
                
                bindingFactoryMethod method = _bindingFactories[viewClass][bindType];
                if(method == nil)
                {
                    continue;
                }
                
                binding = method(view,bindType,wrapper,context);
                if(binding == nil)
                {
                    continue;
                }
                
                // Register this binding against this view
                NSString* viewKey = [NSString stringWithFormat:@"%p", view];
                if(assignedBindings[viewKey] == nil)
                {
                    assignedBindings[viewKey] = [NSMutableSet set];
                }
                [assignedBindings[viewKey] addObject:binding];
                
                [binding updateValue];
                
                break;
            }
            
            if(binding == nil)
            {
                NSLog(@"Error - could not create binding from factory for type %@ of class %@",
                      bindType,
                      NSStringFromClass(view.class));
            }
            
        }
    }
    
    for(UIView* subview in view.subviews)
    {
        [self bindToView:subview context:context];
    }
}


- (void) removeBindingsForView:(UIView*)view
{
    NSString* viewKey = [NSString stringWithFormat:@"%p", view];
    
    for(NSObject<Binding>* binding in assignedBindings[viewKey])
    {
        [binding unbind];
    }
}

@end