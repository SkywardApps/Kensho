//
//  ObservableArray.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableArray.h"
#import "Kensho.h"
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

#pragma mark - ObservableProtocol

- (void) addKenshoObserver:(NSObject<IObserver>*)observer
{
    [observers addObject:observer.weak];
}

- (void) removeKenshoObserver:(NSObject<IObserver>*)observer
{
    [observers removeObject:observer.weak];
}

- (id) value
{
    [ken observableAccessed:self];
    return innerArray;
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

- (BOOL) isNull
{
    return self.value == nil;
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
    return self.objectEnumerator;
}


#pragma mark - Helper methods

- (void) triggerChangeEvent
{
    for(NSString<IObserver>* observer in [observers copy])
    {
        [observer observableUpdated:self];
    }
}

- (void) triggerAddEventFor:(NSObject<IObservable>*)item at:(NSUInteger)index
{
    for(NSString<IObserver>* observer in [observers copy])
    {
        if([observer respondsToSelector:@selector(observable:added:forKey:)])
        {
            [(NSObject<ICollectionObserver>*)observer observable:self added:item forKey:@(index)];
        }
    }
    
}

- (void) triggerRemoveEventFor:(NSObject<IObservable>*)item at:(NSUInteger)index
{
    for(NSString<IObserver>* observer in [observers copy])
    {
        if([observer respondsToSelector:@selector(observable:removed:fromKey:)])
        {
            [(NSObject<ICollectionObserver>*)observer observable:self removed:item fromKey:@(index)];
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

#pragma mark - NSMutableArray overrides

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

@end
