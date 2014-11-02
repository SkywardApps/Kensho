//
//  CalculatedObservable.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "Observable.h"


@interface Computed : Observable<IObserver>

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(NSObject<IObservable>*))calculatorMethod;
- (void) startTracking;
- (void) endTracking;
- (void) updateCalculatedValue;

@end
