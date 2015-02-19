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
#import "NSObject+Observable.h"

@interface TestableLuaObject : NSObject

@property NSString* readWrite;
@property (readonly) NSString* readOnly;
@property double cantDoIt;

- (NSObject*) notAProperty;
- (NSObject*)alsoNotAProperty:(NSNumber*)number;

@end
@implementation TestableLuaObject

- (instancetype)init
{
    if((self = [super init]))
    {
        _readWrite = @"readWrite";
        _readOnly = @"readOnly";
        _cantDoIt = 5.5;
    }
    return self;
}

- (NSObject*)notAProperty
{
    return @1;
}

- (NSObject*)alsoNotAProperty:(NSNumber*)number
{
    return @(number.doubleValue + 5);
}

@end

// Done
@interface TestKenshoLuaWrapper : XCTestCase
{
    Kensho* ken;
}

@end


@interface SingleNest : KenModel
@property SingleNest* nested;
@property NSString* value;
@end

@implementation SingleNest
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
    
    // Start with addition
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"first + second"];
    NSNumber* result = wrapper.currentValue;
    XCTAssertEqualObjects(result, @(54), @"Calculation was not performed correctly");
    
    // subtraction
    result = (NSNumber*)[wrapper evaluate:@"second - first"];
    XCTAssertEqualObjects(result, @(50), @"Calculation was not performed correctly");
    
    // multiplication
    result = (NSNumber*)[wrapper evaluate:@"second * first"];
    XCTAssertEqualObjects(result, @(104), @"Calculation was not performed correctly");
    
    // division
    result = (NSNumber*)[wrapper evaluate:@"second / first"];
    XCTAssertEqualObjects(result, @(26), @"Calculation was not performed correctly");
    
    // power
    result = (NSNumber*)[wrapper evaluate:@"second ^ first"];
    XCTAssertEqualObjects(result, @(2704), @"Calculation was not performed correctly");
    
    // modulus
    result = (NSNumber*)[wrapper evaluate:@"second % first"];
    XCTAssertEqualObjects(result, @(0), @"Calculation was not performed correctly");
    
    
    // addition with constant
    result = (NSNumber*)[wrapper evaluate:@"first + 1"];
    XCTAssertEqualObjects(result, @(3), @"Calculation was not performed correctly");
    result = (NSNumber*)[wrapper evaluate:@"1 + second"];
    XCTAssertEqualObjects(result, @(53), @"Calculation was not performed correctly");
    
    
    // equality
    // We also test basic number equality here because we may have modified the Lua internals
    result = (NSNumber*)[wrapper evaluate:@"1 == 1"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first == 2"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"52 == second"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first == 3"];
    XCTAssertEqualObjects(result, @(NO), @"Calculation was not performed correctly");
    
    
    result = (NSNumber*)[wrapper evaluate:@"first < 5"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first <= 2"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    
    result = (NSNumber*)[wrapper evaluate:@"50 < second"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"52 <= second"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first > 1"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first >= 2"];
    XCTAssertEqualObjects(result, @(YES), @"Calculation was not performed correctly");
    
    result = (NSNumber*)[wrapper evaluate:@"first > 2"];
    XCTAssertEqualObjects(result, @(NO), @"Calculation was not performed correctly");
    
}


- (void) testStrings
{
    NSDictionary* dictionary = @{@"first":@"left", @"second":@"right"};
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"first .. \" hand\""];
    NSString* result = wrapper.currentValue;
    XCTAssertEqualObjects(result, @"left hand", @"Calculation was not performed correctly");
    
    result = (NSString*)[wrapper evaluate:@"\"Always \" .. second"];
    XCTAssertEqualObjects(result, @"Always right", @"Calculation was not performed correctly");
    
    result = (NSString*)[wrapper evaluate:@"first .. second"];
    XCTAssertEqualObjects(result, @"leftright", @"Calculation was not performed correctly");
    
    result = (NSString*)[wrapper evaluate:@"first .. \" to \" .. second"];
    XCTAssertEqualObjects(result, @"left to right", @"Calculation was not performed correctly");
    
    
    // equality
    // We also test basic string equality here because we may have modified the Lua internals
    NSNumber* boolResult = (NSNumber*)[wrapper evaluate:@"\"hello\" == \"hello\""];
    XCTAssertEqualObjects(boolResult, @(YES), @"Calculation was not performed correctly");
    
    boolResult = (NSNumber*)[wrapper evaluate:@"first == \"left\""];
    XCTAssertEqualObjects(boolResult, @(YES), @"Calculation was not performed correctly");
    
    boolResult = (NSNumber*)[wrapper evaluate:@"\"right\" == second"];
    XCTAssertEqualObjects(boolResult, @(YES), @"Calculation was not performed correctly");
    
}

- (void) testMethodCalls
{
    TestableLuaObject* object = [[[TestableLuaObject alloc] init] observe:ken];
    KenshoContext* context = [[KenshoContext alloc] initWithContext:object parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"notAProperty()"];
    NSNumber* result = wrapper.currentValue;
    XCTAssertEqualObjects(result, @1, @"Calculation was not performed correctly"); 
    
    result = (NSNumber*)[wrapper evaluate:@"alsoNotAProperty(5)"];
    XCTAssertEqualObjects(result, @(10), @"Calculation was not performed correctly");
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
    TestableLuaObject* object = [[[TestableLuaObject alloc] init] observe:ken];
    
    KenshoContext* context = [[KenshoContext alloc] initWithContext:object parent:nil];
    
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"cantDoIt + 5"];
    NSNumber* result = (NSNumber*)[wrapper evaluate:@"cantDoIt + 5"];
    XCTAssertEqualObjects(result, @(10.5), @"Calculation was not performed correctly");
    
    // observe wrapper, make sure the change notification fires when we change cantDoIt
    object.cantDoIt = 11.5;
    XCTAssertEqualObjects(wrapper.currentValue, @(16.5), @"Calculation was not performed correctly");
    
    NSString* hw = (NSString*)[wrapper evaluate:@"readWrite"];
    XCTAssertEqualObjects(hw, @"readWrite", @"Calculation was not performed correctly");
    
    // observe wrapper, make sure the change notification fires when we change readWrite
    object.readWrite = @"Hello World";
    
    XCTAssertEqualObjects(wrapper.currentValue, @"Hello World", @"Calculation was not performed correctly");
    
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

- (void) testNestedObject
{
    SingleNest* nest1 = [[SingleNest alloc] initWithKensho:ken];
    nest1.nested = [[SingleNest alloc] initWithKensho:ken];
    nest1.nested.value = @"Correct";
    
    
    KenshoContext* context = [[KenshoContext alloc] initWithContext:nest1 parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:@"nested.value"];
    NSString* hw = (NSString*)wrapper.currentValue;
    XCTAssertEqualObjects(hw, @"Correct", @"Calculation was not performed correctly");
}


- (void) testParameters
{
    NSDictionary* dictionary = @{};
    NSString* lineOfCode = @"\"Hello World\"; p3={test=\"YES\"}; p2=52";
    KenshoContext* context = [[KenshoContext alloc] initWithContext:dictionary parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:lineOfCode];
    NSString* result = (NSString*)[wrapper evaluate:lineOfCode];
    XCTAssertEqualObjects(result, @"Hello World", @"Incorrect string value");
    
    // THe second is a string
    XCTAssertEqualObjects(wrapper.parameters[@"p2"], @52, @"Incorrect number value");
    
    // THe first is a string
    XCTAssertEqualObjects(wrapper.parameters[@"p3"][@"test"], @"YES", @"Incorrect complex value.value");
    
}

- (void) testParametersFromObservables
{
    SingleNest* nest1 = [[SingleNest alloc] initWithKensho:ken];
    nest1.nested = [[SingleNest alloc] initWithKensho:ken];
    nest1.nested.value = @"Correct";
    
    NSString* lineOfCode = @"\"Hello World\"; p3={test=nested.value}; p2=52";
    KenshoContext* context = [[KenshoContext alloc] initWithContext:nest1 parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:lineOfCode];
    NSString* result = (NSString*)[wrapper evaluate:lineOfCode];
    XCTAssertEqualObjects(result, @"Hello World", @"Incorrect string value");
    
    // THe second is a string
    XCTAssertEqualObjects(wrapper.parameters[@"p2"], @52, @"Incorrect number value");
    
    // THe first is a string
    XCTAssertEqualObjects([(ObservablePropertyReference*)wrapper.parameters[@"p3"][@"test"] value], @"Correct", @"Incorrect complex value.value");
    
}


- (void) testParameterDependancy
{
    TestableLuaObject* object = [[[TestableLuaObject alloc] init] observe:ken];
    
    NSString* lineOfCode = @"readOnly; p3={test=readWrite}; p2=cantDoIt";
    KenshoContext* context = [[KenshoContext alloc] initWithContext:object parent:nil];
    KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:context code:lineOfCode];
    NSString* result = (NSString*)[wrapper evaluate:lineOfCode];
    
    XCTAssertEqualObjects(result, @"readOnly", @"Incorrect string value");
    
    // THe second is a string
    XCTAssertEqualObjects([ObservablePropertyReference unwrap:wrapper.parameters[@"p2"]], @5.5, @"Incorrect number value");
    
    // THe first is a string
    XCTAssertEqualObjects([ObservablePropertyReference unwrap:wrapper.parameters[@"p3"][@"test"]], @"readWrite", @"Incorrect complex value.value");
    
    object.readWrite = @"Hello World";
    object.cantDoIt = 11.5;
    
    // THe second is a string
    XCTAssertEqualObjects([ObservablePropertyReference unwrap:wrapper.parameters[@"p2"]], @11.5, @"Incorrect number value");
    
    // THe first is a string
    XCTAssertEqualObjects([ObservablePropertyReference unwrap:wrapper.parameters[@"p3"][@"test"]], @"Hello World", @"Incorrect complex value.value");
    
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
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c3", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__parent.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c2", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__parent.__parent.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
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
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__root.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c2 code:loc];
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
    
    {
        NSString* loc = @"__root.name";
        KenshoLuaWrapper* wrapper = [[KenshoLuaWrapper alloc] initWithKensho:ken context:c3 code:loc];
        
        NSString* result = (NSString*)[wrapper evaluate:loc];
        XCTAssertEqualObjects(result, @"c1", @"Failed basic accessor");
    }
}

@end

