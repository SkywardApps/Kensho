//
//  ObservableString.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableString.h"
#import "../../../Kensho.h"

@implementation ObservableString

- (id) initWithKensho:(Kensho *)ken value:(NSString*)value
{
    if((self = [super initWithKensho:ken value:value]))
    {
    }
    return self;
}

- (void)setStringValue:(NSString *)value
{
    self.value = value;
}

@end
