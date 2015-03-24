//
//  TestUsage.m
//  Kensho
//
//  Created by Nicholas Elliott on 3/22/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kensho/Kensho.h>
#import "BindingBase.h"
#import "WeakProxy.h"
#import "UITextFieldBinding.h"
#import "KenshoLuaWrapper.h"

@interface ObservableTracker : NSObject<IObserver>
@property (readonly) BOOL wasUpdated;
- (void) reset;
@end

@implementation ObservableTracker

- (void) reset
{
    _wasUpdated = NO;
}

- (void) observable:(NSObject*)observableOwner updated:(NSString*)attributeName context:(NSString*)context
{
    _wasUpdated = YES;
}

- (void) observableDeallocated:(NSObject*)observableOwner context:(NSString*)context
{
    
}
@end


#import "../doc/Usage.md"

