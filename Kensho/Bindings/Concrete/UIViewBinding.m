//
//  UIViewBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIViewBinding.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "ObservableAsNumber.h"
#import "ObservableAsObject.h"

@implementation UIViewBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"height"])
    {
        NSNumber* value = self.targetValue.numberValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeHeight];
    }
    
    else if([self.bindingType isEqualToString:@"width"])
    {
        NSNumber* value = self.targetValue.numberValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeWidth];
    }
    
    else if([self.bindingType isEqualToString:@"visible"])
    {
        NSNumber* value = self.targetValue.numberValue;
        [self.targetView setHidden:!value.boolValue];
    }
    else if([self.bindingType isEqualToString:@"alpha"])
    {
        NSNumber* value = self.targetValue.numberValue;
        [self.targetView setAlpha:value.floatValue];
    }
    else if([self.bindingType isEqualToString:@"backgroundColor"])
    {
        UIColor* value = (UIColor*)self.targetValue.objectValue;
        [self.targetView setBackgroundColor:value];
    }
    else if([self.bindingType isEqualToString:@"tintColor"])
    {
        UIColor* value = (UIColor*)self.targetValue.objectValue;
        [self.targetView setTintColor:value];
    }
}


@end
