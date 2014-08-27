//
//  ObservableMap.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/24/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObservableAsEnumerator.h"
#import "Kensho.h"

@interface ObservableMap : NSMutableDictionary<ObservableAsEnumerator>

- (id) initWithKensho:(Kensho*)ken;

- (void) addKenshoObserver:(NSObject<Observer>*)observer;
- (void) removeKenshoObserver:(NSObject<Observer>*)observer;

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt;
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;

@end
