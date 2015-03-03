//
//  TestObservableProxy.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+Observable.h"
#import "Kensho.h"

@interface TestableObject : NSObject

@property NSString* readWrite;
@property (readonly) NSString* readOnly;
@property double cantDoIt;
@property (readonly) NSString* calculatedCombination;

@property TestableObject* parent;
@property (readonly) NSString* parentCombination;

- (int) notAProperty;

@end
@implementation TestableObject

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

- (int)notAProperty
{
    return 1;
}

- (NSString *)calculatedCombination
{
    NSString* rw = self.readWrite;
    NSString* ro = self.readOnly;
    return [NSString stringWithFormat:@"%@.%@", rw, ro];
}

- (NSString *)parentCombination
{
    NSString* rw = self.parent.readWrite;
    NSString* ro = self.parent.readOnly;
    return [NSString stringWithFormat:@"%@.%@", rw, ro];
}

@end


@interface TestObservableProxy : XCTestCase<IObserver>
{
    NSMutableSet* accessedKeys;
    NSMutableSet* changedKeys;
    Kensho* ken;
}

@end

@implementation TestObservableProxy

- (void) key:(NSString*)key accessedOn:(id)target
{
    [accessedKeys addObject:key];
    [ken key:key accessedOn:target];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [changedKeys addObject:keyPath];
}

- (void) observable:(NSObject*)observableOwner updated:(NSString*)attributeName context:(NSString*)context
{
    [changedKeys addObject:attributeName];
}

- (void) observableDeallocated:(NSObject*)observableOwner context:(NSString*)context
{
    
}

- (void) startTracking
{
    [ken startTracking];
}

- (NSDictionary*) endTracking
{
    return
    [ken endTracking];
}


- (void)setUp {
    [super setUp];
    accessedKeys = [NSMutableSet set];
    changedKeys = [NSMutableSet set];
    
    static Kensho* singleKensho = nil;
    if(singleKensho == nil)
        singleKensho = [[Kensho alloc] init];
    ken = singleKensho;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testObservableCalled {    
    // Create a simple object
    TestableObject* object = [[TestableObject alloc] init];
    // wrap it in a proxy
    TestableObject* objectProxy = [object observe:self];
    
    // invoke an attribute get
    XCTAssertEqualObjects(objectProxy.readWrite, @"readWrite");
    XCTAssertEqualObjects(objectProxy.readOnly, @"readOnly");
    XCTAssertEqual(objectProxy.cantDoIt, 5.5);

    // make sure that it flagged it!
    XCTAssert([accessedKeys containsObject:@"readWrite"]);
    XCTAssert([accessedKeys containsObject:@"readOnly"]);
    XCTAssert([accessedKeys containsObject:@"cantDoIt"]);
              
    // invoke a basic method
    XCTAssertEqual([objectProxy notAProperty], 1);
    
    // make sure it wasn't flagged
    XCTAssert(![accessedKeys containsObject:@"notAProperty"]);
}

- (void) testSelfReflectingProperty
{
    // Create a simple object
    TestableObject* object = [[TestableObject alloc] init];
    // wrap it in a proxy
    TestableObject* objectProxy = [object observe:self];
    
    XCTAssertEqualObjects(objectProxy.calculatedCombination, @"readWrite.readOnly");
    
    XCTAssert([accessedKeys containsObject:@"readWrite"]);
    XCTAssert([accessedKeys containsObject:@"readOnly"]);
    XCTAssert([accessedKeys containsObject:@"calculatedCombination"]);
    XCTAssert([changedKeys count] == 0);
    
    //[objectProxy addObserver:self forKeyPath:@"calculatedCombination" options:NSKeyValueObservingOptionNew context:nil];
    //[objectProxy addObserver:self forKeyPath:@"readWrite" options:NSKeyValueObservingOptionNew context:nil];
    [objectProxy addObserver:self attribute:@"readWrite" context:@""];
    [objectProxy addObserver:self attribute:@"calculatedCombination" context:@""];
    
    objectProxy.readWrite = @"changed";
    
    XCTAssert([changedKeys count] > 0);
    XCTAssert([changedKeys containsObject:@"readWrite"]);
    XCTAssert([changedKeys containsObject:@"calculatedCombination"]);
    
    
    [objectProxy removeObserver:self attribute:@"readWrite" context:@""];
    [objectProxy removeObserver:self attribute:@"calculatedCombination" context:@""];
    
}

- (void) testOtherReflectingProperty
{
    
    // Create a simple object
    TestableObject* parent = [[[TestableObject alloc] init] observe:self];
    [self observeAll:parent];
    
    // Create a simple object
    TestableObject* object = [[[TestableObject alloc] init] observe:self];
    [self observeAll:object];
    
    // Verify the parent combination method works with no children
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    XCTAssertEqualObjects(object.parentCombination, @"(null).(null)");
    XCTAssert([accessedKeys containsObject:@"parentCombination"]);
    XCTAssert([accessedKeys containsObject:@"parent"]);
    XCTAssert([accessedKeys count] == 2);
    XCTAssert([changedKeys count] == 0);
    
    // Verify the parentCombination is triggered when parent updates
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    object.parent = parent;
    XCTAssert([changedKeys containsObject:@"parentCombination"]);
    XCTAssert([changedKeys containsObject:@"parent"]);
    XCTAssert([changedKeys count] == 2);
    XCTAssert([accessedKeys count] == 4);
    
    // Verify that parentCombination is automatically triggered if the value is changed on the parent,
    // even without a read of the value first
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    parent.readWrite = @"World";
    XCTAssert([changedKeys containsObject:@"readWrite"]);
    XCTAssert([changedKeys containsObject:@"calculatedCombination"]);
    XCTAssert([changedKeys containsObject:@"parentCombination"]);
    XCTAssert([changedKeys count] == 3);
    XCTAssert([accessedKeys count] == 5);
    
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    XCTAssertEqualObjects(object.parentCombination, @"World.readOnly");
    XCTAssert([changedKeys count] == 0);
    XCTAssert([accessedKeys count] == 4);
    
    // Verify that parentCombination is automatically triggered if the value is changed on the parent,
    // after a read of the value
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    parent.readWrite = @"Hello";
    XCTAssert([changedKeys containsObject:@"readWrite"]);
    XCTAssert([changedKeys containsObject:@"calculatedCombination"]);
    XCTAssert([changedKeys containsObject:@"parentCombination"]);
    XCTAssert([changedKeys count] == 3);
    XCTAssert([accessedKeys count] == 5);
    
    [accessedKeys removeAllObjects];
    [changedKeys removeAllObjects];
    XCTAssertEqualObjects(object.parentCombination, @"Hello.readOnly");
    XCTAssert([changedKeys count] == 0);
    XCTAssert([accessedKeys count] == 4);
    
    [self unobserveAll:object];
    [self unobserveAll:parent];
}

- (void) observeAll:(TestableObject*)object
{
    [object addObserver:self attribute:@"readWrite" context:@""];
    [object addObserver:self attribute:@"readOnly" context:@""];
    [object addObserver:self attribute:@"calculatedCombination" context:@""];
    [object addObserver:self attribute:@"cantDoIt" context:@""];
    [object addObserver:self attribute:@"parent" context:@""];
    [object addObserver:self attribute:@"parentCombination" context:@""];
}

- (void) unobserveAll:(TestableObject*)object
{
    [object removeObserver:self attribute:@"readWrite" context:@""];
    [object removeObserver:self attribute:@"readOnly" context:@""];
    [object removeObserver:self attribute:@"calculatedCombination" context:@""];
    [object removeObserver:self attribute:@"cantDoIt" context:@""];
    [object removeObserver:self attribute:@"parent" context:@""];
    [object removeObserver:self attribute:@"parentCombination" context:@""];
}

@end
