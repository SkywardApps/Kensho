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
}
@end

@implementation WeakProxy

- (id)initWithProxied:(id)object {
    // No init method in superclass
    target = object;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:target];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [target methodSignatureForSelector:aSelector];
}

@end


static const void *WeakProxyHelperKey = &WeakProxyHelperKey;

@implementation NSObject (WeakProxy)

- (id) weak
{
    // don't create a double-proxy
    if(self.isProxy)
    {
        return self;
    }
    
    id weakProxy = objc_getAssociatedObject(self, WeakProxyHelperKey);
    if(weakProxy == nil)
    {
        weakProxy = [[WeakProxy alloc] initWithProxied:self];
        objc_setAssociatedObject(self, WeakProxyHelperKey, weakProxy, OBJC_ASSOCIATION_RETAIN);
    }
    return weakProxy;
}

@end
