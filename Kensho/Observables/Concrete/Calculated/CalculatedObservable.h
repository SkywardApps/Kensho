//
//  CalculatedObservable.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"


@interface CalculatedObservable : ObservableBase<Observer>

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(NSObject<Observable>*))calculatorMethod;
- (void) startTracking;
- (void) endTracking;
- (void) updateCalculatedValue;

@end
