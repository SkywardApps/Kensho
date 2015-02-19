//
//  ObservablePropertyReference.m
//  Kensho
//
//  Created by Nicholas Elliott on 2/19/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import "ObservablePropertyReference.h"
#import "ObservableValue.h"

@implementation ObservablePropertyReference

@synthesize value;

+ (NSObject*) unwrap:(NSObject*)value
{
    if([value isKindOfClass:ObservablePropertyReference.class])
    {
        value = [(ObservablePropertyReference*)value value];
    }
    if([value isKindOfClass:ObservableValue.class])
    {
        value = [(ObservableValue*)value value];
    }
    return value;
}

- (id) initWithOwner:(NSObject*)owner propertyName:(NSString*)name
{
    if((self = [super init]))
    {
        _owner = owner;
        _propertyName = name;
    }
    return self;
}

- (NSObject*) value {
    return [self.owner valueForKey:self.propertyName];
}

@end