//
//  CalculatedObservableNumber.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "CalculatedObservableNumber.h"

@implementation CalculatedObservableNumber

- (id) initWithKensho:(Kensho *)ken calculator:(NSNumber*(^)(NSObject<Observable>*))calculatorMethod
{
    if((self = [super initWithKensho:ken]))
    {
        self.calculatorMethod = calculatorMethod;
    }
    return self;
}

- (NSNumber *)value
{
    [self startTracking];
    NSNumber* value = self.calculatorMethod(self);
    [self endTracking];
    
    return value;
}

- (NSNumber*) numberValue
{
    return self.value;
}


@end
