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
{
    Kensho* ken;
}

@end

@implementation TestKenshoLuaWrapper

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testNumbers
{
    NSDictionary* dictionary = @{@"first":@(2), @"second":@(52)};
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"first + second"];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"first + second"];
    XCTAssertEqualObjects(result, @(54), @"Calculation was not performed correctly");
}

- (void)testRecursive
{
    NSDictionary* dictionary = @{@"first":@(2), @"second":@(52), @"third":@{@"data":@(100)}};
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"first + second + third.data"];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"first + second + third.data"];
    XCTAssertEqualObjects(result, @(154), @"Calculation was not performed correctly");
}

- (void) testObservables
{
    Observable* number = [[Observable alloc] initWithKensho:ken];
    number.value = @(52);
    Observable* string = [[Observable alloc] initWithKensho:ken];
    string.value = @"Hello World";
    
    NSDictionary* dictionary = @{
                                 @"number":number,
                                 @"hello":string
                                 };
    
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"number.value + 5"];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"number.value + 5"];
    XCTAssertEqualObjects(result, @(57), @"Calculation was not performed correctly");
    
    
    NSString* hw = (NSString*)[wrapper evaluate:@"hello.value"];
    XCTAssertEqualObjects(hw, @"Hello World", @"Calculation was not performed correctly");
}

- (void) testComplexObject
{
    NSDictionary* dictionary = @{};
    NSString* lineOfCode = @"{p1=\"Hello World\", p3={test=\"YES\"}, p2=52}";
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:lineOfCode];
    NSDictionary* result = (NSDictionary*)[wrapper evaluate:lineOfCode];
    
    // We should have an object with three entries now
    XCTAssertEqual(result.count, 3, @"Incorrect return type");
    
    // THe first is a string
    XCTAssertEqualObjects(result[@"p1"], @"Hello World", @"Incorrect string value");
    
    // THe second is a string
    XCTAssertEqualObjects(result[@"p2"], @52, @"Incorrect number value");
    
    // THe first is a string
    XCTAssertEqualObjects(result[@"p3"][@"test"], @"YES", @"Incorrect complex value.value");
}

- (void) testParent
{
    NSDictionary* d1 = @{@"name":@"c1"};
    KenshoContext* c1 = [[KenshoContext alloc] initWithContext:d1 parent:nil];
    NSDictionary* d2 = @{@"name":@"c2"};
    KenshoContext* c2 = [[KenshoContext alloc] initWithContext:d2 parent:c1];
    NSDictionary* d3 = @{@"name":@"c3"};
    KenshoContext* c3 = [[KenshoContext alloc] initWithContext:d3 parent:c2];
    
    {
        NSString* loc = @"name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c3", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__parent.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c2", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__parent.__parent.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
}


- (void) testRoot
{
    NSDictionary* d1 = @{@"name":@"c1"};
    KenshoContext* c1 = [[KenshoContext alloc] initWithContext:d1 parent:nil];
    NSDictionary* d2 = @{@"name":@"c2"};
    KenshoContext* c2 = [[KenshoContext alloc] initWithContext:d2 parent:c1];
    NSDictionary* d3 = @{@"name":@"c3"};
    KenshoContext* c3 = [[KenshoContext alloc] initWithContext:d3 parent:c2];
    
    {
        NSString* loc = @"__root.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c1 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__root.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c2 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__root.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = [wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
}

@end
