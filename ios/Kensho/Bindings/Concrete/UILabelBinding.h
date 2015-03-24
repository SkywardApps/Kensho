//
//  UILabelBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindingBase.h"
#import <UIKit/UIKit.h>

@interface UILabelBinding : BindingBase

@property (weak, readonly) UILabel* targetView;

@end


@interface UILabel (KenshoBinding)

@property IBInspectable NSString* dataBindText;
@property IBInspectable NSString* dataBindColor;
@property IBInspectable NSString* dataBindFont;

@end