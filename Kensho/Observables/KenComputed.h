//
//  KenComputed.h
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Kensho;
@interface KenComputed : NSObject

- (id) initWithKensho:(Kensho *)ken calculator:(NSObject*(^)(NSObject*))calculatorMethod;

@property (readonly) NSObject* currentValue;

@end
