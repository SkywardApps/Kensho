//
//  UITextFieldBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 3/10/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import "UITextFieldBinding.h"

@implementation UITextFieldBinding

+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"value"])
    {
        [BindingBase addFactoryNamed:name
                               class:UIView.class
                          collection:ken.bindingFactories
                              method:^(UIView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
         {
             return [[UITextFieldBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
         }];
    }
}

- (id) initWithKensho:(Kensho *)ken target:(UIView *)target type:(NSString *)type value:(NSObject<KenshoValueParameters> *)value context:(NSObject *)context
{
    if((self = [super initWithKensho:ken target:target type:type value:value context:context]))
    {
        [self.targetView addTarget:self action:@selector(valueDidChange) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"text"])
    {
        [self.targetView setText:self.resultValue];
    }    
}

- (void) valueDidChange
{
    // How do we get to the Observable Reference from here?
}

@end
