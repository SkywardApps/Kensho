//
//  ObservableProxy.h
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IObservable.h"

@class Kensho;


@interface NSObject (Observable)

- (id) observableBy:(Kensho*)ken;

@end

@interface ObservableProxy : NSProxy

/**
 *  Basic constructor.
 */
- (id)initWithKensho:(Kensho*)ken proxied:(id)object;

@end
