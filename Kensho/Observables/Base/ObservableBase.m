//
//  ViewModelObject.m
//  Once In A While
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

@property (readonly) NSMutableSet* observers;

@end

@implementation ObservableBase
@synthesize observers=observers;

- (id) initWithKensho:(Kensho*)ken
{
    if((self = [super init]))
    {
        observers = [NSMutableSet set];
        _ken = ken;
    }
    return self;
}

- (void) observedBy:(NSObject<Observer>*)observer
{
    [observers addObject:observer.weak];
}

- (void) unobserve:(NSObject<Observer>*)observer
{
    [observers removeObject:observer.weak];
}

- (void) triggerChangeEvent
{
    for(NSString<Observer>* observer in observers)
    {
        [observer observableUpdated:self];
    }
}

@end
