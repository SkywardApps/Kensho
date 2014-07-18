//
//  ProxyObservableCollection.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/16/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"
#import "ObservableAsEnumerator.h"

typedef NSObject<Observable>* (^ProxyMethod)(NSObject* key, NSObject<Observable>* item);

@interface ProxyObservableArray : NSObject<ObservableAsEnumerator, CollectionObserver>

- (id) initWithKensho:(Kensho*)ken proxying:(NSObject<ObservableAsEnumerator>*)proxied via:(ProxyMethod)proxy;

@property (readonly) NSObject<ObservableAsEnumerator>* proxied;
@property (readonly) ProxyMethod proxy;

- (void) observedBy:(NSObject<Observer>*)observer;
- (void) unobserve:(NSObject<Observer>*)observer;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)objectEnumerator;

@end
