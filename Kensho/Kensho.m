//
//  Kensho.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Kensho.h"
#import "Bindings/Interfaces/Binding.h"
#import "Bindings/Concrete/UIButtonBinding.h"
#import "Bindings/Concrete/UILabelBinding.h"
#import "Bindings/Concrete/UITableViewBinding.h"
#import "Bindings/Concrete/UIViewBinding.h"
#import "Utilities/UIView+Kensho.h"
#import "KenshoContext.h"
#import "KenshoLuaWrapper.h"
#import "Observables/Concrete/Calculated/Computed.h"


typedef NSObject<Binding>* (^bindingFactoryMethod)(UIView* view, NSString* type, NSObject<IObservable>* observable, NSObject* context);

@interface Kensho ()
{
    NSMutableDictionary* bindingFactories;
    NSMutableArray* trackings;
    NSMutableDictionary* assignedBindings;
}

@end

@implementation Kensho

+ (id) unwrapObservable:(id)object
{
    if([object conformsToProtocol:@protocol(IObservable)])
    {
        return [(id<IObservable>)object value];
    }
    return object;
}

- (void) startTracking
{
    [trackings addObject:[NSMutableSet set]];
}

- (void) observableAccessed:(NSObject<IObservable>*)observable
{
    NSMutableSet* set = trackings.lastObject;
    [set addObject:observable];
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
        _errorMessage = [[Observable alloc] initWithKensho:self];
        
        bindingFactories = [NSMutableDictionary dictionary];
        bindingFactories[(id <NSCopying>)UIButton.class] =
        @{
          @"title":^(UIButton* view, NSString* type, NSObject<IObservable>* observable, NSObject* context)
          {
              return [[UIButtonBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          }
          };
        
        bindingFactories[(id <NSCopying>)UILabel.class] =
        @{
          @"text":^(UILabel* view, NSString* type, NSObject<IObservable>* observable, NSObject* context)
          {
              return [[UILabelBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          }
          };
        
        bindingFactories[(id <NSCopying>)UIView.class] =
        @{
          @"height":^(
                      UIView* view, NSString* type, NSObject<IObservable>* observable, NSObject* context)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          },
          @"backgroundColor":^(
                      UIView* view, NSString* type, NSObject<IObservable>* observable, NSObject* context)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          },
          @"tintColor":^(
                      UIView* view, NSString* type, NSObject<IObservable>* observable, NSObject* context)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          }
          };
        
        bindingFactories[(id <NSCopying>)UITableView.class] =
        @{
          @"foreach":^(UITableView* view, NSString* type, NSObject<IObservable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UITableViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context];
          }
          };
        
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
            
            // Now, definitively, the observable passed into any given binding is either a value type,
            // or an NSDictionary of observables/values for multiple parameters
            NSObject<IObservable>* targetValue = [[Computed alloc] initWithKensho:self
                                                calculator:^NSObject *(NSObject<IObservable> *o) {
                                                    return [wrapper evaluate:bindValue];
                                                }];
            
            
            
            // Register this binding against this view
            NSString* viewKey = [NSString stringWithFormat:@"%p", view];
            if(assignedBindings[viewKey] == nil)
            {
                assignedBindings[viewKey] = [NSMutableSet set];
            }
            [assignedBindings[viewKey] addObject:targetValue];
            
            
            // Handle the special-case structural bindings
            if([bindValue isEqualToString:@"with"])
            {
                // We will need to change the context from now on
                // This is an observable... so \todo rebind if this changes
                context = [[KenshoContext alloc] initWithContext:targetValue.value parent:context];
                continue;
            }
            
            NSObject<Binding>* binding = nil;
            
            // iterate through classes and their parents
            Class viewClass = nil;
            while((viewClass = (viewClass == nil ? view.class : [viewClass superclass])))
            {
                // We dispatch based on the view type and the binding type here
                if(bindingFactories[viewClass] == nil)
                {
                    continue;
                }
                
                bindingFactoryMethod method = bindingFactories[viewClass][bindType];
                if(method == nil)
                {
                    continue;
                }
                
                binding = method(view,bindType,targetValue,context);
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