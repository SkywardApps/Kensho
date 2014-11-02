//
//  TestObservableBase.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Observable.h"
#import "Kensho/Kensho.h"

@interface TestObservableBase : XCTestCase<IObserver>
{
    Kensho* ken;
    BOOL observedChanged;
}

@end

@implementation TestObservableBase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observedChanged = NO;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ken = nil;
    [super tearDown];
}

- (void)testConstructor
{
    Observable* base = [[Observable alloc] initWithKensho:ken];
    XCTAssertEqual(ken, base.ken, @"Kensho object not correct");
}

- (void)testObserve
{
    Observable* base = [[Observable alloc] initWithKensho:ken];
    [base addKenshoObserver:self];
    [base triggerChangeEvent];
    XCTAssertEqual(YES, observedChanged, @"Observer was not invoked");
}

- (void)testUnobserve
{
    Observable* base = [[Observable alloc] initWithKensho:ken];
    [base addKenshoObserver:self];
    [base removeKenshoObserver:self];
    [base triggerChangeEvent];
    XCTAssertEqual(NO, observedChanged, @"Observer was invoked");
}

- (void) testRelease
{
    __weak Observable* weakBase;
    @autoreleasepool
    {
        Observable* base = [[Observable alloc] initWithKensho:ken];
        weakBase = base;
        [base addKenshoObserver:self];
        [base removeKenshoObserver:self];
    }
    XCTAssertNil(weakBase, @"Object was not released");
}

#pragma mark - Test Mocks

- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    observedChanged = YES;
}
@end
