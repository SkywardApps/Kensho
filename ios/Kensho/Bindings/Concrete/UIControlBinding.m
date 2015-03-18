//
//  UIControlBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 3/16/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import "UIControlBinding.h"

@implementation UIControlBinding


+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"enabled"])
    {
        [BindingBase addFactoryNamed:name
                               class:UIControl.class
                          collection:ken.bindingFactories
                              method:^(UIView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
         {
             return [[UIControlBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
         }];
    }
}

- (void)updateValue
{
    if([self.bindingType isEqualToString:@"enabled"])
    {
        self.targetView.enabled = [self.resultValue boolValue];
    }
}

@end


@implementation UIControl (Kensho)

- (void) setDataBindEnabled:(NSString *)dataBindEnabled
{
    self.ken[@"enabled"] = dataBindEnabled;
}

- (NSString *)dataBindEnabled
{
    return self.ken[@"enabled"];
}

@end