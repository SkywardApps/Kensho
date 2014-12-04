//
//  WeakProxy.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "WeakProxy.h"
#import <objc/runtime.h>

@interface WeakProxy ()
{
    __weak id target;
    __unsafe_unretained id unsafeTarget;
}
@end

@implementation WeakProxy

- (id)initWithProxied:(id)object
{
    // No init method in superclass
    target = object;
    unsafeTarget = object;
    return self;
}

/**
 *  Pass through all invocations to the target object - so long as it still exists.
 *
 *  @param anInvocation <#anInvocation description#>
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if(target != nil)
    {
        [anInvocation invokeWithTarget:target];
    }
    else{
        [anInvocation invokeWithTarget:self];
    }
}

/**
 *  Pass through signature requests to the target object
 *
 *  @param aSelector The selector to query
 *
 *  @return A method signature
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [target methodSignatureForSelector:aSelector];
}

- (id) strong
{
    return target;
}

- (id) unsafe
{
    return unsafeTarget;
}

@end


static const void *WeakProxyHelperKey = &WeakProxyHelperKey;
static const void *UnsafeProxyHelperKey = &UnsafeProxyHelperKey;

@implementation NSObject (WeakProxy)

/**
 *  Find and return the weak pointer for this object.
 *
 *  @return A weak reference to this object
 */
- (id) weak
{
    // don't create a double-proxy if this is already one.
    if(self.isProxy)
    {
        return self;
    }
    
    // Get the associated weak object for this object.
    id weakProxy = objc_getAssociatedObject(self, WeakProxyHelperKey);
    
    // If there isn't one, create it
    if(weakProxy == nil)
    {
        weakProxy = [[WeakProxy alloc] initWithProxied:self];
        objc_setAssociatedObject(self, WeakProxyHelperKey, weakProxy, OBJC_ASSOCIATION_RETAIN);
    }
    
    return weakProxy;
}

- (id) strong
{
    return self;
}

- (id) unsafe
{
    return self;
}

@end
