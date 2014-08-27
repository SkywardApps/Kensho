//
//  TestKenshoJsContext.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/20/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#import <XCTest/XCTest.h>
#import "KenshoLuaWrapper.h"
#import <Kensho/Kensho.h>


@interface TestKenshoLuaWrapper : XCTestCase

@end

@implementation TestKenshoLuaWrapper

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testNumbers
{
    NSDictionary* dictionary = @{@"first":@(2), @"second":@(52)};
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithTarget:dictionary];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"first + second"];
    XCTAssertEqualObjects(result, @(54), @"Calculation was not performed correctly");
}

- (void)testRecursive
{
    NSDictionary* dictionary = @{@"first":@(2), @"second":@(52), @"third":@{@"data":@(100)}};
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithTarget:dictionary];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"first + second + third.data"];
    XCTAssertEqualObjects(result, @(154), @"Calculation was not performed correctly");
}

- (void) testObservables
{
    Kensho* ken = [[Kensho alloc] init];
    ObservableNumber* number = [[ObservableNumber alloc] initWithKensho:ken];
    number.numberValue = @(52);
    ObservableString* string = [[ObservableString alloc] initWithKensho:ken];
    string.stringValue = @"Hello World";
    
    NSDictionary* dictionary = @{
                                 @"number":number,
                                 @"hello":string
                                 };
    
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithTarget:dictionary];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"number + 5"];
    XCTAssertEqualObjects(result, @(57), @"Calculation was not performed correctly");
    
    
    NSString* hw = (NSString*)[wrapper evaluate:@"hello"];
    XCTAssertEqualObjects(hw, @"Hello World", @"Calculation was not performed correctly");
}

@end
