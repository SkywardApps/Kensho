//
//  ObservableString.m
//  Once In A While
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableString.h"
#import "../../../Kensho.h"

@implementation ObservableString

@synthesize stringValue=_value;

- (void)setStringValue:(NSString *)value
{
    _value = value;
    // trigger the observable event
    [self triggerChangeEvent];
}

- (NSString *)stringValue
{
    [self.ken observableAccessed:self];
    return _value;
}

@end
