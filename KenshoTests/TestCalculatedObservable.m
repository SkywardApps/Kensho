//
//  TestCalculatedObservable.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Kensho/Kensho.h"
#import "CalculatedObservable.h"
#import "WeakProxy.h"

@interface TestCalculatedObservable : XCTestCase<Observer, Observable>
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
    CalculatedObservable* base = [[CalculatedObservable alloc] initWithKensho:ken];
    XCTAssertEqual(ken, base.ken, @"Kensho object not correct");
}

- (void)testObserve
{
    CalculatedObservable* base = [[CalculatedObservable alloc] initWithKensho:ken];
    [base observedBy:self];
    [base triggerChangeEvent];
    XCTAssertEqual(YES, observedChanged, @"Observer was not invoked");
}

- (void)testUnobserve
{
    CalculatedObservable* base = [[CalculatedObservable alloc] initWithKensho:ken];
    [base observedBy:self];
    [base unobserve:self];
    [base triggerChangeEvent];
    XCTAssertEqual(NO, observedChanged, @"Observer was invoked");
}

- (void) testRelease
{
    __weak ObservableBase* weakChanger;
    @autoreleasepool
    {
        ObservableBase* changer = [[ObservableBase alloc] initWithKensho:ken];
        weakChanger = changer;
        __weak CalculatedObservable* weakBase;
        @autoreleasepool
        {
            CalculatedObservable* base = [[CalculatedObservable alloc] initWithKensho:ken];
            weakBase = base;
            [base observedBy:self];
            [base startTracking];
            [ken observableAccessed:changer];
            [base endTracking];
            [base unobserve:self];
        }
        XCTAssertNil(weakBase, @"Object was not released");
    }
    XCTAssertNil(weakChanger, @"Object was not released");
}

- (void) testTracking
{
    CalculatedObservable* base = [[CalculatedObservable alloc] initWithKensho:ken];
    [base startTracking];
    [ken observableAccessed:self];
    [base endTracking];
    
    XCTAssertEqual(base.weak, observers.anyObject, @"Calculated did not observe dependency");
}

#pragma mark - Test Mocks

- (void) observableUpdated:(NSObject<Observable>*)observable
{
    observedChanged = YES;
}

- (void) observedBy:(NSObject<Observer>*)observer
{
    [observers addObject:observer.weak];
}

- (void) unobserve:(NSObject<Observer>*)observer
{
    [observers removeObject:observer.weak];
}

@end
