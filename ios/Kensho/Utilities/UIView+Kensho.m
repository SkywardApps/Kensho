//
//  UIView+Kensho.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIView+Kensho.h"
#import <objc/runtime.h>

@implementation UIView (Kensho)

static const void *KenshoBinderHelperKey = &KenshoBinderHelperKey;

/**
 *  Find the associated dictionary for this object.
 *
 *  @return An editable dictionary
 */
- (NSMutableDictionary *) ken 
{
    NSMutableDictionary* dict = objc_getAssociatedObject(self, KenshoBinderHelperKey);
    if(dict == nil)
    {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, KenshoBinderHelperKey, dict, OBJC_ASSOCIATION_RETAIN);
    }
    return dict;
}

@end


