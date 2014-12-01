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
    __weak id weakTarget;
    __unsafe_unretained id unsafeTarget;
}
@end

@implementation WeakProxy

- (id)initWithProxied:(id)object
{
    // No init method in superclass
    weakTarget = object;
    unsafeTarget = nil;
    return self;
}

- (id)initWithUnretained:(id)object
{
    unsafeTarget = object;
    weakTarget = object;
    return self;
}

/**
 *  Pass through all invocations to the target object - so long as it still exists.
 *
 *  @param anInvocation <#anInvocation description#>
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id target = weakTarget;
    if(target == nil)
    {
        target = unsafeTarget;
    }
    
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
    id target = weakTarget;
    if(target == nil)
    {
        target = unsafeTarget;
    }
    return [target methodSignatureForSelector:aSelector];
}

- (id) strong
{
    return weakTarget;
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

- (id) unsafe
{
    // don't create a double-proxy if this is already one.
    if(self.isProxy)
    {
        return self;
    }
    
    // Get the associated weak object for this object.
    id unsafeProxy = objc_getAssociatedObject(self, UnsafeProxyHelperKey);
    
    // If there isn't one, create it
    if(unsafeProxy == nil)
    {
        unsafeProxy = [[WeakProxy alloc] initWithUnretained:self];
        objc_setAssociatedObject(self, UnsafeProxyHelperKey, unsafeProxy, OBJC_ASSOCIATION_RETAIN);
    }
    
    return unsafeProxy;
}

- (id) strong
{
    return self;
}

@end
