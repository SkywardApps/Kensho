//
//  KenComputed.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenComputed.h"
#import "Kensho.h"

@interface KenComputed ()
{
    NSObject* (^_calculatorMethod)(NSObject*);
    Kensho* ken;
    
    NSDictionary* observing;
}

@end

@implementation KenComputed

@synthesize currentValue=_currentValue;

- (id) initWithKensho:(Kensho *)initialken
           calculator:(NSObject*(^)(NSObject*))calculatorMethod
{
    if((self = [super init]))
    {
        _calculatorMethod = [calculatorMethod copy];
        ken = initialken;
        [self updateCalculatedValue];
    }
    return self;
}

- (NSObject *)currentValue
{
    [ken key:@"currentValue" accessedOn:self];
    return _currentValue;
}

- (void) updateCalculatedValue
{
    [self startTracking];
    NSObject* newValue = _calculatorMethod(self);
    // @todo verify the value has even changed
    [self willChangeValueForKey:@"currentValue"];
    _currentValue = newValue;
    [self endTracking];
    [self didChangeValueForKey:@"currentValue"];
}

- (void)unobserveAll
{
    for(NSString* attribute in observing.allKeys)
    {
        for(NSObject* target in observing[attribute])
        {
            if(target == nil)
            {
                continue;
            }
            
            [target removeObserver:self
                        forKeyPath:attribute];
        }
    }
    observing = nil;
}

- (void) startTracking
{
    [ken key:@"currentValue" accessedOn:self];
    [self unobserveAll];
    [ken startTrackingDirectAccess];
}

- (void) endTracking
{
    NSDictionary* newlyObserved = [ken endTrackingDirectAccess];
    
    // Reference anything we accessed
    for(NSString* attribute in newlyObserved.allKeys)
    {
        for(NSObject* target in newlyObserved[attribute])
        {
            if(target == nil)
            {
                continue;
            }
            
            [target addObserver:self
                     forKeyPath:attribute
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        }
    }
    observing = newlyObserved;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self updateCalculatedValue];
}


- (void)dealloc
{
    [self unobserveAll];
}


@end
