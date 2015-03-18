//
//  UIControlBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 3/16/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <Kensho/Kensho.h>
#import "BindingBase.h"

@interface UIControlBinding : BindingBase

@property (readonly) UIControl* targetView;

@end

@interface UIControl (Kensho)

@property IBInspectable NSString* dataBindEnabled;

@end
