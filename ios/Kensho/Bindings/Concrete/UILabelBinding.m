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
#import "ObservablePropertyReference.h"
#import <UIKit/UIKit.h>

@implementation UILabel (Kensho)

- (void) setDataBindText:(NSString *)kenText
{
    self.ken[@"text"] = kenText;
}

- (NSString *)dataBindText
{
    return self.ken[@"text"];
}

@end

@implementation UILabelBinding

+ (void) registerFactoriesTo:(Kensho*)ken;
{
    for(NSString* type in @[@"text", @"color", @"font"])
    {
        [BindingBase addFactoryNamed:type
                               class:UILabel.class
                          collection:ken.bindingFactories
                              method:^(UILabel* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
         {
             return [[UILabelBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
         }];
    }
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

@end


@implementation UILabel (KenshoBinding)

KENPROP(text, Text);
KENPROP(color, Color);
KENPROP(font, Font);

@end
