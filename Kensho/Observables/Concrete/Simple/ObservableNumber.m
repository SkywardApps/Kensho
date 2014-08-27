//
//  ObservableNumber.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableNumber.h"
#import "../../../Kensho.h"

@implementation ObservableNumber

- (id) initWithKensho:(Kensho *)ken value:(NSNumber*)value
{
    if((self = [super initWithKensho:ken value:value]))
    {
    }
    return self;
}

- (void)setNumberValue:(NSNumber *)value
{
    self.value = value;
}

@end
