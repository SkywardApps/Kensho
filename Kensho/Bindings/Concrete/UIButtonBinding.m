//
//  UIButtonBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UIButtonBinding.h"
#import "ObservableAsString.h"
#import <UIKit/UIKit.h>

@implementation UIButtonBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"title"])
    {
        // easiest way to convert to text
        if(self.targetValue.isString)
        {
            [self.targetView setTitle:self.targetValue.stringValue
                             forState:UIControlStateNormal];
        }
    }
}

@end
