//
//  CalculatedObservable.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "CalculatedObservableString.h"

@implementation CalculatedObservableString

- (id) initWithKensho:(Kensho *)ken calculator:(NSString*(^)(NSObject<Observable>*))calculatorMethod
{
    if((self = [super initWithKensho:ken]))
    {
        self.calculatorMethod = calculatorMethod;
    }
    return self;
}

- (NSString *)value
{   
    [self startTracking];
    NSString* value = self.calculatorMethod(self);
    [self endTracking];
    
    return value;
}

- (NSString*) stringValue
{
    return self.value;
}

@end
