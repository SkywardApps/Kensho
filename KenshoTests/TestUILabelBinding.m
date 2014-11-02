//
//  TestUILabelBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Kensho/Kensho.h>
#import "UILabelBinding.h"
#import "WeakProxy.h"

// Done

@interface TestUILabelBinding : XCTestCase
{
    Kensho* ken;
    Observable* observable;
}

@end

@implementation TestUILabelBinding

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observable = [[Observable alloc] initWithKensho:ken];
    observable.value = @"Initial Title";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ken = nil;
    observable = nil;
    [super tearDown];
}

- (void) testConstructor
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    NSObject* context = [NSDictionary dictionary];
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                                target:label
                                                                  type:@"text"
                                                                 value:observable
                                                               context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(label, binding.targetView, @"Views do not match");
    XCTAssertEqualObjects(@"text", binding.bindingType, @"Types do not match");
    XCTAssertEqual(observable, binding.targetValue, @"Values do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(binding.weak, observable.observers.anyObject, @"Binding did not observe value");
    
    [binding updateValue];
    XCTAssertEqualObjects(observable.value, label.text, @"Binding did not accept initial value");
}


- (void) testUpdateValueText
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                              target:label
                                                                type:@"text"
                                                               value:observable
                                                             context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(label, binding.targetView, @"Views do not match");
    XCTAssertEqualObjects(@"text", binding.bindingType, @"Types do not match");
    XCTAssertEqual(observable, binding.targetValue, @"Values do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    [binding updateValue];
    XCTAssertEqualObjects(observable.value, label.text, @"Binding did not accept initial value");
    
    observable.value = @"Title has changed!";
    [observable triggerChangeEvent];
    
    XCTAssertEqualObjects(observable.value, label.text, @"Binding did not accept updatd value");
    
}


- (void) testUnbind
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                              target:label
                                                                type:@"text"
                                                               value:observable
                                                             context:context];
    
    [binding updateValue];
    [binding unbind];
    
    XCTAssertEqual((UIView*)nil, binding.targetView, @"Views do not match");
    XCTAssertEqual((NSObject*)nil, binding.targetValue, @"Values do not match");
    XCTAssertEqual((NSObject*)nil, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(0, observable.observers.count, @"Binding did not release value");
}


- (void) testRelease
{
    __weak UILabelBinding* weakBinding;
    __weak UILabel* weakLabel;
    __weak NSObject* weakContext;
    
    @autoreleasepool
    {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        weakLabel = label;
        
        NSObject* context = [[Observable alloc] initWithKensho:ken];
        weakContext = context;
        
        UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                                  target:label
                                                                    type:@"text"
                                                                   value:observable
                                                                 context:context];
        weakBinding = binding;
        
        [binding updateValue];
        [binding unbind];
    }
    
    
    XCTAssertNil(weakBinding, @"Object was not released");
    XCTAssertNil(weakContext, @"Object was not released");
    XCTAssertNil(weakLabel, @"Object was not released");
}

@end
