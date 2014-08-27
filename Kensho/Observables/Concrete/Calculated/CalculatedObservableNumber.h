//
//  CalculatedObservableNumber.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "CalculatedObservable.h"
#import "ObservableAsNumber.h"

@interface CalculatedObservableNumber : CalculatedObservable

- (id) initWithKensho:(Kensho *)ken calculator:(NSNumber*(^)(NSObject<Observable>*))calculatorMethod;

@end
