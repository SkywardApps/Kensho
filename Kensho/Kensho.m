//
//  Kensho.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Kensho.h"
#import "Bindings/Interfaces/Binding.h"
#import "Observables/Concrete/Simple/ObservableString.h"
#import "Bindings/Concrete/UIButtonBinding.h"
#import "Bindings/Concrete/UILabelBinding.h"
#import "Bindings/Concrete/UITableViewBinding.h"
#import "Bindings/Concrete/UIViewBinding.h"
#import "Utilities/UIView+Kensho.h"
#import "KenshoLuaWrapper.h"
#import "Observables/Concrete/Calculated/CalculatedObservable.h"


typedef NSObject<Binding>* (^bindingFactoryMethod)(UIView* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters);

@interface Kensho ()
{
    NSMutableDictionary* bindingFactories;
    NSMutableArray* trackings;
    NSMutableDictionary* assignedBindings;
}

@end

@implementation Kensho

- (void) startTracking
{
    [trackings addObject:[NSMutableSet set]];
}

- (void) observableAccessed:(NSObject<Observable>*)observable
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
        _errorMessage = [[ObservableString alloc] initWithKensho:self];
        
        bindingFactories = [NSMutableDictionary dictionary];
        bindingFactories[(id <NSCopying>)UIButton.class] =
        @{
          @"title":^(UIButton* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UIButtonBinding alloc] initWithKensho:self target:view type:type value:observable context:context parameters:parameters];
          }
          };
        
        bindingFactories[(id <NSCopying>)UILabel.class] =
        @{
          @"text":^(UILabel* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UILabelBinding alloc] initWithKensho:self target:view type:type value:observable context:context parameters:parameters];
          }
          };
        
        bindingFactories[(id <NSCopying>)UIView.class] =
        @{
          @"height":^(
                      UIView* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context parameters:parameters];
          },
          @"backgroundColor":^(
                      UIView* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context  parameters:parameters];
          },
          @"tintColor":^(
                      UIView* view, NSString* type, NSObject<Observable>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UIViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context  parameters:parameters];
          }
          };
        
        bindingFactories[(id <NSCopying>)UITableView.class] =
        @{
          @"foreach":^(UITableView* view, NSString* type, NSObject<ObservableAsEnumerator>* observable, NSObject* context, NSDictionary* parameters)
          {
              return [[UITableViewBinding alloc] initWithKensho:self target:view type:type value:observable context:context  parameters:parameters];
          }
          };
        
        trackings = [NSMutableArray array];
        assignedBindings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) applyBindings:(UIView*)rootView viewModel:(NSObject*)model
{
    [self bindToView:rootView context:model];
}

- (void) bindToView:(UIView *)view context:(NSObject*)object
{
    NSObject* context = object;
    
    // verify the format  ..... label: .....
    if(view.ken.allKeys.count > 0)
    {
        for(NSString* bindType in view.ken.allKeys)
        {
            NSString* bindValue = view.ken[bindType];
            
            // First of all, split this into the regular expression pattern
            // that catches an optional start of
            //   attribute
            //   ?calculation
            // optionally combined with a series of tokens
            //   param:attribute ...
            //   param:?calculation ...
            //
            // This allows us to do the simple case
            //   ken.height -> viewHeight
            //   ken.height -> ?items.count + 88
            //   ken.foreach -> items where:includeInList
            //   ken.foreach -> items where:?name != "include"
            
            // the first token may match the format (0 or 1)
            // (^\?[^:]+[\s$])|(^[_a-zA-Z][a-zA-Z0-9._]*[\s$])
            // Susequent tokens may match the format (0 - N)
            // ([_a-zA-Z][_a-zA-Z0-9.]*)\s*:\s*([_a-zA-Z][_a-zA-Z0-9.]*)
            // or
            // ([_a-zA-Z][_a-zA-Z0-9.]*)\s*:\s*(\?[^:]+[\s$])
            
            // figure out the bindValue referenced here
            // or do we pass that off to the factory and just provide the 'context'?
            NSObject<Observable>* targetValue;
            NSDictionary* parameters = nil;
            
            if([bindValue characterAtIndex:0] == '?')
            {
                // firstToken is now a lua script
                KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:self context:context code:bindValue];
                
                // evaluate once to a) generate the initial values and b) generate the parameters
                //id firstEval = [wrapper evaluate:bindValue];
                parameters = wrapper.parameters;
                NSString* token = [bindValue substringFromIndex:1];
                
                targetValue = [[CalculatedObservable alloc] initWithKensho:self
                                                                      calculator:^NSObject *(NSObject<Observable> *o) {
                                                                          return (NSObject*)[wrapper evaluate:token];
                                                                      }];
                
                // Register this binding against this view
                NSString* viewKey = [NSString stringWithFormat:@"%p", view];
                if(assignedBindings[viewKey] == nil)
                {
                    assignedBindings[viewKey] = [NSMutableSet set];
                }
                [assignedBindings[viewKey] addObject:targetValue];
            
            }
            else
            {
                targetValue = [context valueForKeyPath:bindValue];
            }
            
            // Handle the special-case structural bindings
            if([bindValue isEqualToString:@"with"])
            {
                context = targetValue;
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
                
                binding = method(view,bindType,targetValue,context,parameters);
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
                NSLog(@"Error - could not create binding from factory for type %@ of class %@", bindType, NSStringFromClass(view.class));
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