//
//  ObservableObject.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableObject.h"

@implementation ObservableObject


- (id) initWithKensho:(Kensho *)ken value:(NSObject*)value
{
    if((self = [super initWithKensho:ken value:value]))
    {
    }
    return self;
}

- (void)setObjectValue:(id)value
{
    self.value = value;
}
@end
