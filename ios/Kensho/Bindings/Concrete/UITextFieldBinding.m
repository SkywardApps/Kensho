//
//  UITextFieldBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 3/10/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import "UITextFieldBinding.h"
#import "ObservablePropertyReference.h"

@implementation UITextField (Kensho)

- (void) setDataBindText:(NSString *)kenText
{
    self.ken[@"text"] = kenText;
}

- (NSString *)dataBindText
{
    return self.ken[@"text"];
}

@end

@implementation UITextFieldBinding

+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"text"])
    {
        [BindingBase addFactoryNamed:name
                               class:UITextField.class
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
        if(![self.targetView.text isEqualToString:self.resultValue])
        {
            [self.targetView setText:self.resultValue];
        }
    }
}

- (void) valueDidChange
{
    NSLog(@"Value Changed");
    // How do we get to the Observable Reference from here?
    NSObject* boundValue = self.observedValue.parameters[@"__final"];
    if([boundValue isKindOfClass:[ObservablePropertyReference class]])
    {
        ObservablePropertyReference* reference = (ObservablePropertyReference*)boundValue;
        NSLog(@"Assigning value to %@", reference.propertyName);
        [reference.owner setValue:self.targetView.text forKey:reference.propertyName];
    }
    
}

@end
