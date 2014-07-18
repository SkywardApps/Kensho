//
//  BindingBase.m
//  Once In A While
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "BindingBase.h"
#import <UIKit/UIKit.h>

@implementation BindingBase


+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<Observable>*)value context:(NSObject*)context
{
    if((self = [super init]))
    {
        _targetView = target;
        _targetValue = value;
        _bindingType = type;
        _ken = ken;
        _context = context;
        
        [value observedBy:self];
    }
    return self;
}

- (void) observableUpdated:(NSObject<Observable>*)observable
{
    [self updateValue];
}

- (void) unbind
{
    _targetView = nil;
    [self.targetValue unobserve:self];
    _targetValue = nil;
    _bindingType = nil;
    _context = nil;
}

- (void) updateValue
{
    @throw [NSException exceptionWithName:@"NotYetImplemented"
                                   reason:[NSString stringWithFormat:@"Class %@ must overload and implement updateValue", NSStringFromClass(self.class)]
                                 userInfo:nil];
}

@end
