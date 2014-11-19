//
//  ProxyObservableCollection.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/16/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ComputedArray.h"
#import "../../../Kensho.h"
#import "WeakProxy.h"

@interface ComputedArray ()
{
    NSMutableArray* innerArray;
    NSMutableSet* observers;
    Kensho* ken;
}

@end

@implementation ComputedArray


- (id) initWithKensho:(Kensho*)initialKen proxying:(NSObject<IObservable>*)proxied via:(ProxyMethod)proxy
{
    if((self = [super init]))
    {
        ken = initialKen;
        observers = [NSMutableSet set];
        innerArray = [NSMutableArray array];
        _proxied = proxied;
        _proxy = proxy;
        
        // Ok, make sure we have all the elements needed currently
        NSEnumerator* enumerator = [proxied.value objectEnumerator];
        NSObject<IObservable>* item;
        while((item = [enumerator nextObject]))
        {
            [innerArray addObject:self.proxy(@(innerArray.count), item)];
        }
        
        // Now observe for changes
        [proxied addKenshoObserver:self];
    }
    return self;
}

- (NSUInteger)hash
{
    return innerArray.hash;
}

- (id)valueForKey:(NSString *)key
{
    if([key isEqualToString:@"count"])
    {
        return @(self.count);
    }
    return [super valueForKey:key];
}

#pragma mark - Observable protocol

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

- (BOOL) isNull
{
    return self.value == nil;
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


#pragma mark - Helpers for emitting events
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

#pragma mark - Basic NSArray interface

- (NSUInteger)count
{
    [ken observableAccessed:self];
    return innerArray.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    [ken observableAccessed:self];
    return innerArray[index];
}

- (NSEnumerator *)objectEnumerator
{
    [ken observableAccessed:self];
    return innerArray.objectEnumerator;
}


- (NSEnumerator*) enumeratorValue
{
    return [self objectEnumerator];
}

#pragma mark - CollectionObserver

- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    // relay the change
    [self triggerChangeEvent];
}

- (void) observable:(NSObject<IObservable>*)observable added:(NSObject<IObservable>*)item forKey:(NSObject*)key
{
    NSObject<IObservable>* translated = self.proxy(key, item);
    [innerArray insertObject:translated atIndex:[(NSNumber*)key integerValue]];
    [self triggerAddEventFor:translated at:[(NSNumber*)key integerValue]];
    
    // We don't trigger the change event here as an optimization, since we know the proxied object is about to
    // and we'll relay that anyway
}

- (void) observable:(NSObject<IObservable>*)observable removed:(NSObject<IObservable>*)item fromKey:(NSObject*)key
{
    NSObject<IObservable>* oldItem = innerArray[[(NSNumber*)key integerValue]];
    [innerArray removeObjectAtIndex:[(NSNumber*)key integerValue]];
    [self triggerRemoveEventFor:oldItem at:[(NSNumber*)key integerValue]];
    
    // We don't trigger the change event here as an optimization, since we know the proxied object is about to
    // and we'll relay that anyway
}

@end