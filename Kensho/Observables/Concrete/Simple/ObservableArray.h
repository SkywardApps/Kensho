//
//  ObservableArray.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Observable.h"

@class Kensho;

@interface ObservableArray : NSMutableArray<IObservable>

- (id) initWithKensho:(Kensho*)ken;

- (void) addKenshoObserver:(NSObject<IObserver>*)observer;
- (void) removeKenshoObserver:(NSObject<IObserver>*)observer;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSEnumerator *)objectEnumerator;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

@end
