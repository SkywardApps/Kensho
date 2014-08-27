//
//  ObservableMap.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/24/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableMap.h"
#import "WeakProxy.h"

@interface ObservableMap ()
{
    NSMutableDictionary* innerMap;
    NSMutableSet* observers;
    Kensho* ken;
}

@end

@implementation ObservableMap

- (id) initWithKensho:(Kensho*)inken
{
    if((self = [super init]))
    {
        ken = inken;
        observers = [[NSMutableSet alloc] init];
        innerMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithKensho:(Kensho*)inken
                       objects:(const id [])objects
                       forKeys:(const id<NSCopying> [])keys
                         count:(NSUInteger)cnt
{
    if((self = [super initWithObjects:objects
                              forKeys:keys
                                count:cnt]))
    {
        ken = inken;
    }
    return self;
}

- (NSUInteger)hash
{
    return innerMap.hash;
}

#pragma mark - ObservableProtocol

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
    [ken observableAccessed:self];
    return innerMap;
}

- (NSString*) stringValue
{
    return nil;
}

- (NSNumber*) numberValue
{
    return nil;
}

- (NSObject*) objectValue
{
    return self.value;
}

- (BOOL) isNumber
{
    return NO;
}

- (BOOL) isString
{
    return NO;
}

- (BOOL) isObject
{
    return NO;
}

- (BOOL) isList
{
    return YES;
}

- (BOOL) isMap
{
    return NO;
}


- (BOOL) isCollection
{
    return YES;
}


- (NSEnumerator *)enumeratorValue
{
    [ken observableAccessed:self];
    return innerMap.objectEnumerator;
}

#pragma mark - Helper methods

- (void) triggerChangeEvent
{
    for(NSString<Observer>* observer in [observers copy])
    {
        [observer observableUpdated:self];
    }
}

- (void) triggerAddEventFor:(NSObject<Observable>*)item at:(NSUInteger)index
{
    for(NSString<Observer>* observer in [observers copy])
    {
        if([observer respondsToSelector:@selector(observable:added:forKey:)])
        {
            [(NSObject<CollectionObserver>*)observer observable:self added:item forKey:@(index)];
        }
    }
    
}

- (void) triggerRemoveEventFor:(NSObject<Observable>*)item at:(NSUInteger)index
{
    for(NSString<Observer>* observer in [observers copy])
    {
        if([observer respondsToSelector:@selector(observable:removed:fromKey:)])
        {
            [(NSObject<CollectionObserver>*)observer observable:self removed:item fromKey:@(index)];
        }
    }
}

- (id)valueForKey:(NSString *)key
{
    if([key isEqualToString:@"count"])
    {
        return @(self.count);
    }
    return [super valueForKey:key];
}

#pragma mark - NSMutableDictionary

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    if((self = [super init]))
    {
        observers = [[NSMutableSet alloc] init];
        innerMap = [[NSMutableDictionary alloc] initWithObjects:objects
                                                        forKeys:keys
                                                          count:cnt];
    }
    return self;
    
}

- (NSUInteger)count
{
    [ken observableAccessed:self];
    return innerMap.count;
}

- (id)objectForKey:(id)aKey
{
    [ken observableAccessed:self];
    return [innerMap objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    [ken observableAccessed:self];
    return [innerMap keyEnumerator];
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    return [innerMap setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    [innerMap removeObjectForKey:aKey];
}
@end
