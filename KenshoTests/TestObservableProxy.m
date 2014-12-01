//
//  TestObservableProxy.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ObservableProxy.h"
#import "Kensho.h"

@interface TestableObject : NSObject

@property NSString* readWrite;
@property (readonly) NSString* readOnly;
@property double cantDoIt;
@property (readonly) NSString* calculatedCombination;

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

@end


@interface TestObservableProxy : XCTestCase
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

- (void) startTrackingDirectAccess
{
    [ken startTrackingDirectAccess];
}

- (NSDictionary*) endTrackingDirectAccess
{
    return
    [ken endTrackingDirectAccess];;
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
    TestableObject* objectProxy = [object observableBy:self];
    
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
    TestableObject* objectProxy = [object observableBy:self];
    
    XCTAssertEqualObjects(objectProxy.calculatedCombination, @"readWrite.readOnly");
    
    XCTAssert([accessedKeys containsObject:@"readWrite"]);
    XCTAssert([accessedKeys containsObject:@"readOnly"]);
    XCTAssert([accessedKeys containsObject:@"calculatedCombination"]);
    XCTAssert([changedKeys count] == 0);
    
    [objectProxy addObserver:self forKeyPath:@"calculatedCombination" options:NSKeyValueObservingOptionNew context:nil];
    [objectProxy addObserver:self forKeyPath:@"readWrite" options:NSKeyValueObservingOptionNew context:nil];
    
    objectProxy.readWrite = @"changed";
    
    XCTAssert([changedKeys count] > 0);
    XCTAssert([changedKeys containsObject:@"readWrite"]);
    XCTAssert([changedKeys containsObject:@"calculatedCombination"]);
    
    
    [objectProxy removeObserver:self forKeyPath:@"readWrite"];
    [objectProxy removeObserver:self forKeyPath:@"calculatedCombination"];
    
}

- (void) testOtherReflectingProperty
{
    
}



@end
