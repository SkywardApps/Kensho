//
//  UILabelBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UILabelBinding.h"
#import "IObservable.h"
#import "Kensho.h"
#import <UIKit/UIKit.h>

@implementation UILabelBinding

+ (void) registerFactoriesTo:(Kensho*)ken;
{
    [BindingBase addFactoryNamed:@"text"
                           class:UILabel.class
                      collection:ken.bindingFactories
                          method:^(UILabel* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
     {
         return [[UILabelBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
     }];
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"text"])
    {
        [self.targetView setText:self.resultValue];
    }
}

@end
