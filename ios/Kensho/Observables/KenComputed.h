//
//  KenComputed.h
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IObservable.h"
#import "ObservableValue.h"
@class Kensho;

@interface KenComputed : ObservableValue<IObserver, IObservable>

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(KenComputed*))calculatorMethod;

@property (copy, nonatomic) NSObject*(^calculatorMethod)(KenComputed*);
@property (readonly) id value;

@end
