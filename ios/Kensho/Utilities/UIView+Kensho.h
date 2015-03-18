//
//  UIView+Kensho.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This category extends UIViews to support a dictionary property that redirects to 
 * our kensho instance for bindings.
 */
@interface UIView (Kensho)

/**
 *  An additional property exposed on views for the sole purpose of binding in interface builder
 */
@property (readonly) IBInspectable NSMutableDictionary* ken;

@end
