//
//  CalculatedObservable.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Computed.h"
#import "Kensho.h"

@interface Computed ()
{
    NSObject* (^_calculatorMethod)(NSObject<IObservable>*);
}

@end

@implementation Computed

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(NSObject<IObservable>*))calculatorMethod
{
    if((self = [super initWithKensho:ken]))
    {
        _calculatorMethod = [calculatorMethod copy];
        [self updateCalculatedValue];
    }
    return self;
}

- (void) updateCalculatedValue
{
    [self startTracking];
    self.value = _calculatorMethod(self);
    [self endTracking];
}

- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    [self updateCalculatedValue];
    [self triggerChangeEvent];
}

- (void) startTracking
{
    [self.ken observableAccessed:self];
    [self.ken startTracking];
}

- (void) endTracking
{
    NSSet* newlyObserved = [self.ken endTracking];
    
    // Reference anything we accessed
    for(NSObject<IObservable>* observedInstance in newlyObserved)
    {
        [observedInstance addKenshoObserver:self];
    }    
}

@end
