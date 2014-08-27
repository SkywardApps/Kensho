//
//  CalculatedObservable.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "CalculatedObservable.h"
#import "ObservableAsString.h"

@interface CalculatedObservableString : CalculatedObservable

- (id) initWithKensho:(Kensho *)ken calculator:(NSString*(^)(NSObject<Observable>*))calculatorMethod;

@property (nonatomic, copy) NSString* (^calculatorMethod)(NSObject<Observable>*);
@property (readonly, nonatomic) NSString* value;

@end
