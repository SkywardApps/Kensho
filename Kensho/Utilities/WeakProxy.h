//
//  WeakProxy.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Category on NSObject to return a weak version of self.  This uses a static cache
 *  so that all requests for a weak pointer return the same one.
 */
@interface NSObject (WeakProxy)

/**
 *  Find and return the weak pointer for this object.
 *
 *  @return A weak reference to this object
 */
- (id) weak;

- (id) unsafe;

- (id) strong;

@end

/**
 *  A class that extends NSProxy to create a 'weak' wrapping object around a concrete class.
 * This allows us to transparently turn any object into a weak reference - good for collections.
 */
@interface WeakProxy : NSProxy

/**
 *  Basic constructor.
 *
 *  @param object The concrete object to be proxied
 *
 *  @return Initialized WeakProxy
 */
- (id)initWithProxied:(id)object;

- (id) unsafe;

- (id) strong;

@end
