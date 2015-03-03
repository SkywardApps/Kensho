//
//  UIButtonBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIButtonBinding.h"
#import <UIKit/UIKit.h>
#import "Kensho.h"

@implementation UIButtonBinding

+ (void) registerFactoriesTo:(Kensho*)ken;
{
    [BindingBase addFactoryNamed:@"title"
                           class:UIButton.class
                      collection:ken.bindingFactories
                          method:^(UIButton* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
     {
         return [[UIButtonBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
     }];
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"title"])
    {
        // easiest way to convert to text
        [self.targetView setTitle:self.resultValue forState:UIControlStateNormal];
    }
}

@end
