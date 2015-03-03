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

+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"height", @"backgroundColor", @"tintColor"])
    {
        [BindingBase addFactoryNamed:name
                               class:UIView.class
                          collection:ken.bindingFactories
                              method:^(UIView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
         {
             return [[UIViewBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
         }];
    }
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"height"])
    {
        NSNumber* value = (NSNumber*)self.resultValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeHeight];
    }
    
    else if([self.bindingType isEqualToString:@"width"])
    {
        NSNumber* value = (NSNumber*)self.resultValue;
        [self.targetView setConstraintConstant:value.floatValue forAttribute:NSLayoutAttributeWidth];
    }
    
    else if([self.bindingType isEqualToString:@"visible"])
    {
        NSNumber* value = (NSNumber*)self.resultValue;
        [self.targetView setHidden:!value.boolValue];
    }
    else if([self.bindingType isEqualToString:@"alpha"])
    {
        NSNumber* value = (NSNumber*)self.resultValue;
        [self.targetView setAlpha:value.floatValue];
    }
    else if([self.bindingType isEqualToString:@"backgroundColor"])
    {
        UIColor* value = (UIColor*)self.resultValue;
        [self.targetView setBackgroundColor:value];
    }
    else if([self.bindingType isEqualToString:@"tintColor"])
    {
        UIColor* value = (UIColor*)self.resultValue;
        [self.targetView setTintColor:value];
    }
}


@end
