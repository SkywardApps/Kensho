//
//  UIImageViewBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 3/16/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BindingBase.h"

@interface UIImageViewBinding : BindingBase

@property (weak, readonly) UIImageView* targetView;

@end


@interface UIImageView (Kensho)

@property IBInspectable NSString* dataBindSource;
@property IBInspectable NSString* dataBindPath;

@end
