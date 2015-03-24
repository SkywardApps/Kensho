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
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "ObservablePropertyReference.h"


@implementation UIViewBinding

+ (void) registerFactoriesTo:(Kensho*)ken
{
    for(NSString* name in @[@"height", @"width", @"visible", @"opacity", @"backgroundColor", @"tintColor",
                            @"border"])
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
    else if([self.bindingType isEqualToString:@"opacity"])
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
    else if([self.bindingType isEqualToString:@"border"])
    {
        CGFloat frameWidth = 1;
        CGColorRef frameColor = UIColor.blackColor.CGColor;
        CGFloat cornerRadius = 0;
        
        if([self.resultValue isKindOfClass:UIColor.class])
        {
            frameColor =((UIColor*)self.resultValue).CGColor;
        }
        else if([self.resultValue isKindOfClass:NSNumber.class])
        {
            frameWidth = [((NSNumber*)self.resultValue) floatValue];
        }
        else if([self.resultValue isKindOfClass:NSDictionary.class])
        {
            // look for all three attributes
            UIColor* color = [self.resultValue valueForKey:@"color"];
            if([color isKindOfClass:UIColor.class])
            {
                frameColor = color.CGColor;
            }
            NSNumber* width = [self.resultValue valueForKey:@"width"];
            if([width isKindOfClass:NSNumber.class])
            {
                frameWidth = width.floatValue;
            }
            
            NSNumber* corner = [self.resultValue valueForKey:@"cornerRadius"];
            if([corner isKindOfClass:NSNumber.class])
            {
                cornerRadius = corner.floatValue;
            }
        }
        
        NSObject* color = [ObservablePropertyReference unwrap:self.observedValue.parameters[@"color"]];
        if([color isKindOfClass:UIColor.class])
        {
            frameColor = ((UIColor*)color).CGColor;
        }
        
        NSObject* width = [ObservablePropertyReference unwrap:self.observedValue.parameters[@"width"]];
        if([width isKindOfClass:NSNumber.class])
        {
            frameWidth = [((NSNumber*)width) floatValue];
        }
        
        NSObject* corner = [ObservablePropertyReference unwrap:self.observedValue.parameters[@"cornerRadius"]];
        if([corner isKindOfClass:NSNumber.class])
        {
            cornerRadius = [((NSNumber*)corner) floatValue];
        }
        
        self.targetView.layer.borderWidth = frameWidth;
        self.targetView.layer.borderColor = frameColor;
        self.targetView.layer.cornerRadius = cornerRadius;
    }
}

@end


@implementation UIView (KenshoBindings)

KENPROP(visible, Visible);
KENPROP(opacity, Opacity);
KENPROP(backgroundColor, BackgroundColor);
KENPROP(border, Border);

@end
