//
//  TestUIButtonBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Kensho/Kensho.h>
#import "UIButtonBinding.h"
#import "WeakProxy.h"

@interface TestUIButtonBinding : XCTestCase
{
    Kensho* ken;
    ObservableString* observableString;
}

@end

@implementation TestUIButtonBinding

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observableString = [[ObservableString alloc] initWithKensho:ken value:@"Initial Title"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    observableString = nil;
    ken = nil;
    [super tearDown];
}

- (void) testConstructor
{
    UIButton* underlyingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    id btn = OCMPartialMock(underlyingButton);
    
    NSObject* context = [NSDictionary dictionary];
    UIButtonBinding* binding = [[UIButtonBinding alloc] initWithKensho:ken
                                                                target:btn
                                                                  type:@"title"
                                                                 value:observableString
                                                               context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(btn, binding.targetView, @"Views do not match");
    XCTAssertEqualObjects(@"title", binding.bindingType, @"Types do not match");
    XCTAssertEqual(observableString, binding.targetValue, @"Values do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(binding.weak, observableString.observers.anyObject, @"Binding did not observe value");
    
    [binding updateValue];
    
    OCMVerify([btn setTitle:observableString.stringValue forState:UIControlStateNormal]);
}


- (void) testUpdateValueTitle
{
    UIButton* underlyingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    id btn = OCMPartialMock(underlyingButton);
    
    NSObject* context = [NSDictionary dictionary];
    UIButtonBinding* binding = [[UIButtonBinding alloc] initWithKensho:ken
                                                        target:btn
                                                          type:@"title"
                                                         value:observableString
                                                       context:context];
    
    [binding updateValue];
    
    OCMVerify([btn setTitle:observableString.stringValue forState:UIControlStateNormal]);
    
    observableString.stringValue = @"Title has changed!";
    
    OCMVerify([btn setTitle:observableString.stringValue forState:UIControlStateNormal]);
    
}

- (void) testUnbind
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    UIButtonBinding* binding = [[UIButtonBinding alloc] initWithKensho:ken
                                                        target:btn
                                                          type:@"title"
                                                         value:observableString
                                                       context:context];
    
    [binding updateValue];
    [binding unbind];
    
    XCTAssertEqual((UIView*)nil, binding.targetView, @"Views do not match");
    XCTAssertEqual((NSObject*)nil, binding.targetValue, @"Values do not match");
    XCTAssertEqual((NSObject*)nil, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(0, observableString.observers.count, @"Binding did not release value");
}


- (void) testRelease
{
    __weak UIButtonBinding* weakBinding;
    __weak UIButton* weakButton;
    __weak NSObject* weakContext;
    __weak ObservableString* weakValue;
    
    @autoreleasepool
    {
        weakValue = observableString;
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        weakButton = btn;
        
        NSObject* context = [[ObservableString alloc] initWithKensho:ken];
        weakContext = context;
        
        UIButtonBinding* binding = [[UIButtonBinding alloc] initWithKensho:ken
                                                            target:btn
                                                              type:@"type"
                                                             value:observableString
                                                           context:context];
        weakBinding = binding;
        
        [binding updateValue];
        [binding unbind];
        observableString = nil;
    }
    
    
    XCTAssertNil(weakBinding, @"Object was not released");
    XCTAssertNil(weakContext, @"Object was not released");
    XCTAssertNil(weakButton, @"Object was not released");
    XCTAssertNil(weakValue, @"Object was not released");
}




@end
