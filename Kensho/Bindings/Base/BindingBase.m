//
//  BindingBase.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "BindingBase.h"
#import <UIKit/UIKit.h>

@implementation BindingBase


+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

/**
 *  Interesting issue here
 *  We may get a binding of '42'
 *  We may get a binding of observable
 *  We may also get a binding of observableTest?observable1:observable2
 *  What this means is that we may have a value, an observable, or a computed that
 *  returns a value or observable.
 *  So we need to test for all three cases!?!?!
 */
- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject*)value context:(NSObject*)context
{
    if((self = [super init]))
    {
        _targetView = target;
        _targetValue = value;
        _bindingType = type;
        _ken = ken;
        _context = context;
        
        if([value conformsToProtocol:@protocol(IObservable) ])
        {
            [(NSObject<IObservable>*)value addKenshoObserver:self];
        }
        [self bindToResultsIfNeeded];
    }
    return self;
}

- (id) finalValue
{
    // If we're bound to a result value, return it's value
    if(_boundResultValue)
    {
        return _boundResultValue.value;
    }
    // Other if we're bound to an observable, return it's value
    if([_targetValue conformsToProtocol:@protocol(IObservable) ])
    {
        return [(NSObject<IObservable>*)_targetValue value];
    }
    
    return _targetValue;
}

- (void) bindToResultsIfNeeded
{
    if([_targetValue conformsToProtocol:@protocol(IObservable) ])
    {
        NSObject<IObservable>* toBindTo = nil;
        // evaluate the result, see if we need to bind to it as well!
        NSObject* resultingValue = [(NSObject<IObservable>*)_targetValue objectValue];
        if([resultingValue conformsToProtocol:@protocol(IObservable)])
        {
            toBindTo = (NSObject<IObservable>*)resultingValue;
        }
        
        // If this has changed, update our bindings
        if(_boundResultValue != toBindTo)
        {
            if(_boundResultValue != nil)
            {
                [_boundResultValue removeKenshoObserver:self];
            }
            
            _boundResultValue = toBindTo;
            
            if(toBindTo != nil)
            {
                [_boundResultValue addKenshoObserver:self];
            }
        
        }
    }
}

- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    [self bindToResultsIfNeeded];
    [self updateValue];
}

- (void) unbind
{
    _targetView = nil;
    
    if([self.targetValue conformsToProtocol:@protocol(IObservable) ])
    {
        [(NSObject<IObservable>*)self.targetValue removeKenshoObserver:self];
    }
    _targetValue = nil;
    _bindingType = nil;
    _context = nil;
}

- (void) updateValue
{
    @throw [NSException exceptionWithName:@"NotYetImplemented"
                                   reason:[NSString stringWithFormat:@"Class %@ must overload and implement updateValue", NSStringFromClass(self.class)]
                                 userInfo:nil];
}

@end
