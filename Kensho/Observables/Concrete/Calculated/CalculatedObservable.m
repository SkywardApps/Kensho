//
//  CalculatedObservable.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "CalculatedObservable.h"
#import "../../../Kensho.h"

@interface CalculatedObservable ()
{
    NSObject* (^_calculatorMethod)(NSObject<Observable>*);
}

@end

@implementation CalculatedObservable

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(NSObject<Observable>*))calculatorMethod
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

- (void) observableUpdated:(NSObject<Observable>*)observable
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
    for(NSObject<Observable>* observedInstance in newlyObserved)
    {
        [observedInstance addKenshoObserver:self];
    }    
}

@end
