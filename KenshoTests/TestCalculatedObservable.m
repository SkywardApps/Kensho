//
//  TestCalculatedObservable.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kensho/Kensho.h"
#import "Computed.h"
#import "WeakProxy.h"

@interface TestCalculatedObservable : XCTestCase<IObserver, IObservable>
{
    Kensho* ken;
    BOOL observedChanged;
    NSMutableSet* observers;
}

@end

@implementation TestCalculatedObservable

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observedChanged = NO;
    observers = [NSMutableSet set];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ken = nil;
    observers = nil;
    [super tearDown];
}


- (void)testConstructor
{
    Computed* base = [[Computed alloc] initWithKensho:ken];
    XCTAssertEqual(ken, base.ken, @"Kensho object not correct");
}

- (void)testObserve
{
    Computed* base = [[Computed alloc] initWithKensho:ken];
    [base addKenshoObserver:self];
    [base triggerChangeEvent];
    XCTAssertEqual(YES, observedChanged, @"Observer was not invoked");
}

- (void)testUnobserve
{
    Computed* base = [[Computed alloc] initWithKensho:ken];
    [base addKenshoObserver:self];
    [base removeKenshoObserver:self];
    [base triggerChangeEvent];
    XCTAssertEqual(NO, observedChanged, @"Observer was invoked");
}

- (void) testRelease
{
    __weak Observable* weakChanger;
    @autoreleasepool
    {
        Observable* changer = [[Observable alloc] initWithKensho:ken];
        weakChanger = changer;
        __weak Computed* weakBase;
        @autoreleasepool
        {
            Computed* base = [[Computed alloc] initWithKensho:ken];
            weakBase = base;
            [base addKenshoObserver:self];
            [base startTracking];
            [ken observableAccessed:changer];
            [base endTracking];
            [base removeKenshoObserver:self];
        }
        XCTAssertNil(weakBase, @"Object was not released");
    }
    XCTAssertNil(weakChanger, @"Object was not released");
}

- (void) testTracking
{
    Computed* base = [[Computed alloc] initWithKensho:ken];
    [base startTracking];
    [ken observableAccessed:self];
    [base endTracking];
    
    XCTAssertEqual(base.weak, observers.anyObject, @"Calculated did not observe dependency");
}

#pragma mark - Test Mocks

- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    observedChanged = YES;
}

- (void) addKenshoObserver:(NSObject<IObserver>*)observer
{
    [observers addObject:observer.weak];
}

- (void) removeKenshoObserver:(NSObject<IObserver>*)observer
{
    [observers removeObject:observer.weak];
}

@end
