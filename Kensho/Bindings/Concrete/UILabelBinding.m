//
//  UILabelBinding.m
//  Once In A While
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UILabelBinding.h"
#import "ObservableBase.h"
#import "ObservableAsString.h"

#import <UIKit/UIKit.h>

@implementation UILabelBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (void) updateValue
{
    if([self.bindingType isEqualToString:@"text"])
    {
        // easiest way to convert to text
        if([self.targetValue conformsToProtocol:@protocol(ObservableAsString)])
        {
            [(UILabel*)self.targetView setText:[(NSObject<ObservableAsString>*)self.targetValue stringValue]];
        }
    }
}

@end
