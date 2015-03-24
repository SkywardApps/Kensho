//
//  UIImageViewBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 3/16/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import "UIImageViewBinding.h"
#import "Kensho.h"

@implementation UIImageViewBinding

+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"source", @"path"])
    {
        [BindingBase addFactoryNamed:name
                               class:UIImageView.class
                          collection:ken.bindingFactories
                              method:^(UIView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
         {
             return [[UIImageViewBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
         }];
    }
}


- (void) updateValue
{
    if([self.bindingType isEqualToString:@"source"])
    {
        UIImage* image = [UIImage imageNamed:self.resultValue];
        self.targetView.image = image;
    }
    else if([self.bindingType isEqualToString:@"path"])
    {
        UIImage* image = [UIImage imageWithContentsOfFile:self.resultValue];
        self.targetView.image = image;
    }
}


@end

@implementation UIImageView (Kensho)

KENPROP(source, Source);
KENPROP(path, Path);

@end
