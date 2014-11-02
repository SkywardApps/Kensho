//
//  UILabelBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UILabelBinding.h"
#import "IObservable.h"
#import "Kensho.h"
#import <UIKit/UIKit.h>

@implementation UILabelBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"text"])
    {
        [self.targetView setText:self.finalValue];
    }
}

@end
