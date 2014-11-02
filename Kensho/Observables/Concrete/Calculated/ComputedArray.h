//
//  ProxyObservableCollection.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/16/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Kensho.h"
#import "IObservable.h"

typedef NSObject<IObservable>* (^ProxyMethod)(NSObject* key, NSObject<IObservable>* item);

/**
 *  A ComputedArray is an array that proxies another.  
 *
 *  This is a basic transformation - so a 1-1 entity relationship,
 *  generally speaking, but the entities in this proxy may (and should) be of a different type than the underlying.
 *
 *  Basically, this provides for a way to create a ViewModel from a DataModel
 */
@interface ComputedArray : NSArray<IObservable, ICollectionObserver>

- (id) initWithKensho:(Kensho*)ken proxying:(NSObject<IObservable>*)proxied via:(ProxyMethod)proxy;

@property (readonly) NSObject<IObservable>* proxied;
@property (readonly) ProxyMethod proxy;

- (void) addKenshoObserver:(NSObject<IObserver>*)observer;
- (void) removeKenshoObserver:(NSObject<IObserver>*)observer;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)objectEnumerator;

@end
