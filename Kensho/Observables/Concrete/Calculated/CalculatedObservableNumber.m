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
    if((self = [super initWithKensho:ken calculator:calculatorMethod]))
    {
    }
    return self;
}

@end
