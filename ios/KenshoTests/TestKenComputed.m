//
//  TestKenComputed.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+Observable.h"
#import "KenComputed.h"
#import "Kensho.h"

@interface ComputedTestableObject : NSObject
@property NSString* readWriteOne;
@property NSString* readWriteTwo;
@property double cantDoIt;
@end

@implementation ComputedTestableObject
- (instancetype)init
{
    if((self = [super init]))
    {
        _readWriteOne = @"One";
        _readWriteTwo = @"Two";
        _cantDoIt = 5.5;
    }
    return self;
}
@end


@interface TestKenComputed : XCTestCase<IObserver>
{
    Kensho* ken;
    NSMutableSet* changedKeys;
}

@end

@implementation TestKenComputed

- (void)observable:(NSObject *)observableOwner updated:(NSString *)attributeName context:(NSString *)context
{
    [changedKeys addObject:attributeName];
}

- (void)observableDeallocated:(NSObject *)observableOwner context:(NSString *)context
{}

- (void)setUp {
    [super setUp];
    static Kensho* singleKensho = nil;
    if(singleKensho == nil)
        singleKensho = [[Kensho alloc] init];
    ken = singleKensho;
    
    changedKeys = [NSMutableSet set];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleComputed
{
    KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        return @(1);
    }];
    XCTAssertEqualObjects(computed.value, @(1));
}

- (void)testOneLevel
{
    ComputedTestableObject* objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
    KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        return [NSString stringWithFormat:@"%@.%@",
                objectOne.readWriteOne, objectOne.readWriteTwo];
    }];
    
    [computed addObserver:self attribute:@"value" context:@""];
    XCTAssertEqualObjects(computed.value, @"One.Two");
    
    XCTAssert(![changedKeys containsObject:@"value"]);
    objectOne.readWriteTwo = @"Zero";
    XCTAssert([changedKeys containsObject:@"value"]);
    XCTAssertEqualObjects(computed.value, @"One.Zero");
}

- (void)testBasicValue
{
    ComputedTestableObject* objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
    KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        return [NSString stringWithFormat:@"%0.1f", objectOne.cantDoIt];
    }];
    [computed addObserver:self attribute:@"value" context:@""];
    XCTAssertEqualObjects(computed.value, @"5.5");
    
    XCTAssert(![changedKeys containsObject:@"value"]);
    objectOne.cantDoIt = 300.1;
    XCTAssert([changedKeys containsObject:@"value"]);
    
    XCTAssertEqualObjects(computed.value, @"300.1");
}

- (void) testMultipleDependencies
{
    ComputedTestableObject* objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
    ComputedTestableObject* objectTwo = [[[ComputedTestableObject alloc] init] observe:ken];
    
    KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        NSString* str = [NSString stringWithFormat:@"%@.%@ %@.%@",
                           objectOne.readWriteOne, objectOne.readWriteTwo,
                           objectTwo.readWriteOne, objectTwo.readWriteTwo];
        return str;
    }];
    [computed addObserver:self attribute:@"value" context:@""];
    XCTAssertEqualObjects(computed.value, @"One.Two One.Two");
    
    XCTAssert(![changedKeys containsObject:@"value"]);
    objectOne.readWriteOne = @"Zero";
    XCTAssert([changedKeys containsObject:@"value"]);
    
    XCTAssertEqualObjects(computed.value, ([NSString stringWithFormat:@"%@.%@ %@.%@",
                                                             objectOne.readWriteOne, objectOne.readWriteTwo,
                                                             objectTwo.readWriteOne, objectTwo.readWriteTwo]));
    
    [changedKeys removeAllObjects];
    objectTwo.readWriteTwo = @"Four";
    XCTAssert([changedKeys containsObject:@"value"]);
    
    XCTAssertEqualObjects(computed.value, ([NSString stringWithFormat:@"%@.%@ %@.%@",
                                                   objectOne.readWriteOne, objectOne.readWriteTwo,
                                                   objectTwo.readWriteOne, objectTwo.readWriteTwo]));
}

- (void)testTwoLevels
{
    ComputedTestableObject* objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
    KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        return [NSString stringWithFormat:@"%@.%@",
                objectOne.readWriteOne, objectOne.readWriteTwo];
    }];
    
    KenComputed* computed2 = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
        return [NSString stringWithFormat:@"%@.%@",
                computed.value, @"End"];
    }];
    
    [computed2 addObserver:self attribute:@"value" context:@""];
    XCTAssertEqualObjects(computed2.value, @"One.Two.End");
    
    XCTAssert(![changedKeys containsObject:@"value"]);
    objectOne.readWriteTwo = @"Zero";
    XCTAssert([changedKeys containsObject:@"value"]);
    
    XCTAssertEqualObjects(computed2.value, @"One.Zero.End");
}

- (void) testDeallocObservableFirst
{
    __weak ComputedTestableObject* weakObject = nil;
    __weak KenComputed* weakComputed = nil;
    {
        KenComputed* computed = nil;
        {
            ComputedTestableObject* objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
            
            weakObject = objectOne;
            computed = [[KenComputed alloc] initWithKensho:ken
                                                calculator:^NSObject *(NSObject * this) {
                return [NSString stringWithFormat:@"%@.%@",
                        weakObject.readWriteOne,
                        weakObject.readWriteTwo];
            }];
            weakComputed = computed;
            XCTAssertEqualObjects(computed.value, @"One.Two");
            
            objectOne.readWriteTwo = @"Zero";
            
            XCTAssertEqualObjects(computed.value, @"One.Zero");
            objectOne = nil;
        }
        XCTAssert(weakObject == nil);
        XCTAssert(weakComputed != nil);
        
        computed = nil;
    }
    XCTAssert(weakComputed == nil);
}

- (void) testDeallocComputedFirst
{
    __weak KenComputed* weakComputed = nil;
    __weak ComputedTestableObject* weakObject = nil;
    {
        ComputedTestableObject* objectOne = nil;
        {
            objectOne = [[[ComputedTestableObject alloc] init] observe:ken];
            weakObject = objectOne;
            KenComputed* computed = [[KenComputed alloc] initWithKensho:ken calculator:^NSObject *(NSObject * this) {
                return [NSString stringWithFormat:@"%@.%@",
                        weakObject.readWriteOne, weakObject.readWriteTwo];
            }];
            weakComputed = computed;
            XCTAssertEqualObjects(computed.value, @"One.Two");
            
            objectOne.readWriteTwo = @"Zero";
            
            XCTAssertEqualObjects(computed.value, @"One.Zero");
            computed = nil;
        }
        XCTAssert(weakComputed == nil);
        XCTAssert(weakObject != nil);
        objectOne = nil;
    }
    XCTAssert(weakObject == nil);
}

@end
