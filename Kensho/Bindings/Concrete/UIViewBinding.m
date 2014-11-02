//
//  UIViewBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIViewBinding.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Kensho.h"
@implementation UIViewBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"height"])
    {
        NSNumber* value = self.finalValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeHeight];
    }
    
    else if([self.bindingType isEqualToString:@"width"])
    {
        NSNumber* value = self.finalValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeWidth];
    }
    
    else if([self.bindingType isEqualToString:@"visible"])
    {
        NSNumber* value = self.finalValue;
        [self.targetView setHidden:!value.boolValue];
    }
    else if([self.bindingType isEqualToString:@"alpha"])
    {
        NSNumber* value = self.finalValue;
        [self.targetView setAlpha:value.floatValue];
    }
    else if([self.bindingType isEqualToString:@"backgroundColor"])
    {
        UIColor* value = (UIColor*)self.finalValue;
        [self.targetView setBackgroundColor:value];
    }
    else if([self.bindingType isEqualToString:@"tintColor"])
    {
        UIColor* value = (UIColor*)self.finalValue;
        [self.targetView setTintColor:value];
    }
}


@end
