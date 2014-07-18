//
//  UIView+UpdateAutoLayoutConstraints.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UpdateAutoLayoutConstraints)

- (BOOL) setConstraintConstant:(CGFloat)constant forAttribute:(NSLayoutAttribute)attribute;
- (CGFloat) constraintConstantforAttribute:(NSLayoutAttribute)attribute;
- (NSLayoutConstraint*) constraintForAttribute:(NSLayoutAttribute)attribute;
- (void)hideView:(BOOL)hidden byAttribute:(NSLayoutAttribute)attribute;
- (void)hideByHeight:(BOOL)hidden;
- (void)hideByWidth:(BOOL)hidden;
- (CGSize) getSize;
- (void)sizeToSubviews;

@end
