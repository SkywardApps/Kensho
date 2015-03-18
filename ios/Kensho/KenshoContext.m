//
//  KenshoContext.m
//  Kensho
//
//  Created by Nicholas Elliott on 8/27/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenshoContext.h"

@implementation KenshoContext


- (id) initWithContext:(id)context parent:(KenshoContext*)parent
{
    if((self = [super init]))
    {
        _context = context;
        if(parent)
        {
            _parent = parent;
            _root = _parent.root;
        }
        else
        {
            _parent = nil;
            _root = self;
        }
    }
    return self;
}

/**
 * Access to to viewmodel OR self if prefixed with a $
 */
- (id)valueForKey:(NSString *)key
{
    if(key.length > 2 && [key characterAtIndex:0] == '_' && [key characterAtIndex:1] == '_')
    {
        return [super valueForKey:[key substringFromIndex:2]];
    }
    else
    {
        return [_context valueForKey:key];
    }
}


/**
 * Setting a view model
 */
- (void) setValue:(id)value forKey:(NSString *)key
{
    [_context setValue:value forKey:key];
}

@end
