//
//  UIButtonBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindingBase.h"
#import <UIKit/UIKit.h>

@interface UIButtonBinding : BindingBase

@property (weak, readonly) UIButton* targetView;

@end


@interface UIButton (Kensho)

@property IBInspectable NSString* dataBindTitle;

@end