//
//  UITextFieldBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 3/10/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <Kensho/Kensho.h>
#import "BindingBase.h"

@interface UITextFieldBinding : BindingBase

@property (weak, readonly) UITextField* targetView;

@end


@interface UITextField (KenshoBinding)

@property IBInspectable NSString* dataBindText;
@property IBInspectable NSString* dataBindColor;
@property IBInspectable NSString* dataBindFont;

@end