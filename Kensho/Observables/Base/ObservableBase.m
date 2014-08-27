//
//  ViewModelObject.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"
#import "../../Kensho.h"
#import "WeakProxy.h"

@interface ObservableBase ()
{
    NSMutableSet* observers;
}

@end

@implementation ObservableBase
@synthesize observers=observers, value=_value;

- (id) initWithKensho:(Kensho*)ken
{
    if((self = [super init]))
    {
        observers = [NSMutableSet set];
        _ken = ken;
    }
    return self;
}

- (id) initWithKensho:(Kensho*)ken value:(id)value
{
    if((self = [self initWithKensho:ken]))
    {
        self.value = value;
    }
    return self;
}

- (void) triggerChangeEvent
{
    for(NSString<Observer>* observer in [observers copy])
    {
        [observer observableUpdated:self];
    }
}

#pragma mark - Observable Protocol

- (void) addKenshoObserver:(NSObject<Observer>*)observer
{
    [observers addObject:observer.weak];
}

- (void) removeKenshoObserver:(NSObject<Observer>*)observer
{
    [observers removeObject:observer.weak];
}

- (id) value
{
    [_ken observableAccessed:self];
    return _value;
}

- (void)setValue:(id)value
{
    if((value == nil && _value != nil)
       || (value != nil && _value == nil)
       || (value != nil && _value != nil && ![_value isEqual:value]))
    {
        _value = value;
        [self triggerChangeEvent];
    }
}

- (NSString*) stringValue
{
    if(self.isString)
    {
        return _value;
    }
    return nil;
}

- (NSNumber*) numberValue
{
    if(self.isNumber)
    {
        return _value;
    }
    return nil;
}

- (NSObject*) objectValue
{
    if(self.isObject)
    {
        return _value;
    }
    return nil;
}

- (BOOL) isNumber
{
    return [_value isKindOfClass:NSNumber.class];
}

- (BOOL) isString
{
    return [_value isKindOfClass:NSString.class];
}

- (BOOL) isObject
{
    return !(self.isNumber || self.isString || self.isList || self.isMap);
}

- (BOOL) isList
{
    return [_value isKindOfClass:NSArray.class];
}

- (BOOL) isMap
{
    return [_value isKindOfClass:NSDictionary.class];
}

- (BOOL) isCollection
{
    return (self.isList || self.isMap);
}

@end
