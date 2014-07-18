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

@interface TestUILabelBinding : XCTestCase<ObservableAsString>
{
    Kensho* ken;
    NSMutableSet* observers;
}

@property (readonly) NSString *stringValue;

@end

@implementation TestUILabelBinding

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observers = [NSMutableSet set];
    _stringValue = @"Initial Title";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ken = nil;
    observers = nil;
    [super tearDown];
}

- (void) testConstructor
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    NSObject* context = [NSDictionary dictionary];
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                                target:label
                                                                  type:@"text"
                                                                 value:self
                                                               context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(label, binding.targetView, @"Views do not match");
    XCTAssertEqualObjects(@"text", binding.bindingType, @"Types do not match");
    XCTAssertEqual(self, binding.targetValue, @"Values do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(binding.weak, observers.anyObject, @"Binding did not observe value");
    
    [binding updateValue];
    XCTAssertEqualObjects(_stringValue, label.text, @"Binding did not accept initial value");
}


- (void) testUpdateValueText
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                              target:label
                                                                type:@"text"
                                                               value:self
                                                             context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(label, binding.targetView, @"Views do not match");
    XCTAssertEqualObjects(@"text", binding.bindingType, @"Types do not match");
    XCTAssertEqual(self, binding.targetValue, @"Values do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    [binding updateValue];
    XCTAssertEqualObjects(_stringValue, label.text, @"Binding did not accept initial value");
    
    _stringValue = @"Title has changed!";
    [self triggerChangeEvent];
    
    XCTAssertEqualObjects(_stringValue, label.text, @"Binding did not accept updatd value");
    
}


- (void) testUnbind
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                              target:label
                                                                type:@"text"
                                                               value:self
                                                             context:context];
    
    [binding updateValue];
    [binding unbind];
    
    XCTAssertEqual((UIView*)nil, binding.targetView, @"Views do not match");
    XCTAssertEqual((NSObject*)nil, binding.targetValue, @"Values do not match");
    XCTAssertEqual((NSObject*)nil, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(0, observers.count, @"Binding did not release value");
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
        
        NSObject* context = [[ObservableString alloc] initWithKensho:ken];
        weakContext = context;
        
        UILabelBinding* binding = [[UILabelBinding alloc] initWithKensho:ken
                                                                  target:label
                                                                    type:@"text"
                                                                   value:self
                                                                 context:context];
        weakBinding = binding;
        
        [binding updateValue];
        [binding unbind];
    }
    
    
    XCTAssertNil(weakBinding, @"Object was not released");
    XCTAssertNil(weakContext, @"Object was not released");
    XCTAssertNil(weakLabel, @"Object was not released");
}

#pragma mark - Test Mocks

- (void) observedBy:(NSObject<Observer>*)observer
{
    [observers addObject:observer.weak];
}

- (void) unobserve:(NSObject<Observer>*)observer
{
    [observers removeObject:observer.weak];
}

- (void) triggerChangeEvent
{
    for(NSString<Observer>* observer in observers)
    {
        [observer observableUpdated:self];
    }
}
@end
