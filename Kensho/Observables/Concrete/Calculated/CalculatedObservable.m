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
}

@end

@implementation CalculatedObservable

- (void) observableUpdated:(NSObject<Observable>*)observable
{
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
        [observedInstance observedBy:self];
    }    
}

@end
