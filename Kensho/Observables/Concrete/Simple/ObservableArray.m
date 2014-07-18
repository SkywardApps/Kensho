//
//  ObservableArray.m
//  Once In A While
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableArray.h"
#import "../../../Kensho.h"
#import "WeakProxy.h"

@interface ObservableArray ()
{
    NSMutableArray* innerArray;
    NSMutableSet* observers;
    Kensho* ken;
}

@end

@implementation ObservableArray

- (id) initWithKensho:(Kensho*)initialKen
{
    if((self = [super init]))
    {
        innerArray = [[NSMutableArray alloc] init];
        observers = [[NSMutableSet alloc] init];
        ken = initialKen;
    }
    return self;
}

- (NSUInteger)hash
{
    return innerArray.hash;
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


- (NSUInteger)count
{
    [ken observableAccessed:self];
    return innerArray.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    [ken observableAccessed:self];
    return [innerArray objectAtIndex:index];
}

- (NSEnumerator *)objectEnumerator
{
    [ken observableAccessed:self];
    return [innerArray objectEnumerator];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [innerArray insertObject:anObject atIndex:index];
    [self triggerAddEventFor:anObject at:index];
    [self triggerChangeEvent];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    id item = innerArray[index];
    [innerArray removeObjectAtIndex:index];
    [self triggerRemoveEventFor:item at:index];
    [self triggerChangeEvent];
}

- (void)removeLastObject
{
    id item = innerArray.lastObject;
    [innerArray removeLastObject];
    [self triggerRemoveEventFor:item at:innerArray.count];
    [self triggerChangeEvent];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    id oldItem = innerArray[index];
    [innerArray replaceObjectAtIndex:index withObject:anObject];
    [self triggerRemoveEventFor:oldItem at:index];
    [self triggerAddEventFor:anObject at:index];
    [self triggerChangeEvent];
}

- (NSEnumerator *)enumeratorValue
{
    return self.objectEnumerator;
}


@end
