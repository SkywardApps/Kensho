//
//  UIButtonBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIButtonBinding.h"
#import <UIKit/UIKit.h>
#import "Kensho.h"

@implementation UIButtonBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"title"])
    {
        // easiest way to convert to text
        [self.targetView setTitle:self.finalValue forState:UIControlStateNormal];
    }
}

@end
