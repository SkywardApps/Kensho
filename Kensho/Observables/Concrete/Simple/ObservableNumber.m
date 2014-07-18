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

@synthesize numberValue=_value;

- (void)setNumberValue:(NSNumber *)value
{
    _value = value;
    // trigger the observable event
    [self triggerChangeEvent];
}


- (NSNumber *)numberValue
{
    [self.ken observableAccessed:self];
    return _value;
}

@end
