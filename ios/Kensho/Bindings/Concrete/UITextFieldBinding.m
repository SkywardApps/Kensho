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
    for(NSString* name in @[@"text", @"color", @"font"])
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
        if([@"text" isEqualToString:type])
        {
            [self.targetView addTarget:self action:@selector(valueDidChange) forControlEvents:UIControlEventEditingChanged];
        }
    }
    return self;
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"text"])
    {
        [self.targetView setText:self.resultValue];
    }
    else if([self.bindingType isEqualToString:@"color"])
    {
        [self.targetView setTextColor:self.resultValue];
    }
    else if([self.bindingType isEqualToString:@"font"])
    {
        CGFloat fontSize = self.targetView.font.pointSize;
        NSString* fontName = self.targetView.font.fontName;
        
        if([self.resultValue isKindOfClass:NSString.class])
        {
            fontName = self.resultValue;
        }
        else if([self.resultValue isKindOfClass:NSNumber.class])
        {
            fontSize = [self.resultValue floatValue];
        }
        else if([self.resultValue isKindOfClass:NSDictionary.class])
        {
            NSDictionary* collection = self.resultValue;
            if([collection[@"size"] isKindOfClass:NSNumber.class])
            {
                fontSize = [collection[@"size"] floatValue];
            }
            if([collection[@"name"] isKindOfClass:NSString.class])
            {
                fontName = collection[@"name"];
            }
        }
        
        NSNumber* parSize = [ObservablePropertyReference unwrap:self.observedValue.parameters[@"size"]];
        if([parSize isKindOfClass:NSNumber.class])
        {
            fontSize = parSize.floatValue;
        }
        
        NSString* parName = [ObservablePropertyReference unwrap:self.observedValue.parameters[@"name"]];
        if([parName isKindOfClass:NSString.class])
        {
            fontName = parName;
        }
        
        self.targetView.font = [UIFont fontWithName:fontName size:fontSize];
    }
}

- (void) valueDidChange
{
    // How do we get to the Observable Reference from here?
    NSObject* boundValue = self.observedValue.parameters[@"__final"];
    if([boundValue isKindOfClass:[ObservablePropertyReference class]])
    {
        ObservablePropertyReference* reference = (ObservablePropertyReference*)boundValue;
        NSObject* value = [reference.owner valueForKey:reference.propertyName];
        if( [value isKindOfClass:ObservableValue.class])
        {
            ObservableValue* obs = (ObservableValue*)value;
            obs.value = self.targetView.text;
        }
        else if(value == nil || ![self.targetView.text isEqual:value])
        {
            [reference.owner setValue:self.targetView.text forKey:reference.propertyName];
        }
    }
    
}

@end


@implementation UITextField (KenshoBinding)

KENPROP(text, Text);
KENPROP(color, Color);
KENPROP(font, Font);

@end
