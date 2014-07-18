//
//  WeakProxy.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WeakProxy)

- (id) weak;

@end

@interface WeakProxy : NSProxy

- (id)initWithProxied:(id)object;

@end
