//
//  UIViewBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "BindingBase.h"
#import <UIKit/UIKit.h>

@interface UIViewBinding : BindingBase

@end

/*
 X opacity
 X border {color, width[number or box], corner-radius}
 X background-color
 background-image [source, size [size, 'fit', 'cover'], width, height, offset-x, offset-y, repeating]
 overflow ('hide, show, scroll')
 X visible
 gravity ['left', 'right', 'center', 'top', 'bottom', 'topleft', 'topright', 'bottomleft', 'bottomright']
 margin (number or box)
 padding (number or box)
 width (percent, dp, sp, px?)
 height (percent, dp, sp, px?)
 */
@interface UIView (KenshoBindings)

@property IBInspectable NSString* dataBindVisible;
@property IBInspectable NSString* dataBindOpacity;
@property IBInspectable NSString* dataBindBorder;
@property IBInspectable NSString* dataBindBackgroundColor;

@end
