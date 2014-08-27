//
//  TestBindingBase.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Kensho/Kensho.h>
#import "BindingBase.h"
#import "WeakProxy.h"

@interface TestBindingBase : XCTestCase<Observable>
{
    Kensho* ken;
    NSMutableSet* observers;
}


@end

@implementation TestBindingBase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ken = [[Kensho alloc] init];
    observers = [NSMutableSet set];
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
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    BindingBase* binding = [[BindingBase alloc] initWithKensho:ken
                                                                target:btn
                                                                  type:@"type"
                                                                 value:self
                                                               context:context];
    
    XCTAssertEqual(ken, binding.ken, @"Kensho does not match");
    XCTAssertEqual(btn, binding.targetView, @"Views do not match");
    XCTAssertEqual(self, binding.targetValue, @"Values do not match");
    XCTAssertEqual(@"type", binding.bindingType, @"Types do not match");
    XCTAssertEqual(context, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(binding.weak, observers.anyObject, @"Binding did not observe value");
    
}


- (void) testUpdateValue
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    BindingBase* binding = [[BindingBase alloc] initWithKensho:ken
                                                        target:btn
                                                          type:@"type"
                                                         value:self
                                                       context:context];
    XCTAssertThrowsSpecificNamed([binding updateValue], NSException, @"NotYetImplemented", @"updateValue must report an exception for not being implemented");
}

- (void) testUnbind
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    NSObject* context = [NSDictionary dictionary];
    
    BindingBase* binding = [[BindingBase alloc] initWithKensho:ken
                                                        target:btn
                                                          type:@"type"
                                                         value:self
                                                       context:context];
    
    [binding unbind];
    
    XCTAssertEqual((UIView*)nil, binding.targetView, @"Views do not match");
    XCTAssertEqual((NSObject*)nil, binding.targetValue, @"Values do not match");
    XCTAssertEqual((NSObject*)nil, binding.context, @"Contexts do not match");
    
    XCTAssertEqual(0, observers.count, @"Binding did not release value");
}


- (void) testRelease
{
    __weak BindingBase* weakBinding;
    __weak UIButton* weakButton;
    __weak NSObject* weakContext;
    
    @autoreleasepool
    {
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        weakButton = btn;
        
        NSObject* context = [[ObservableString alloc] initWithKensho:ken];
        weakContext = context;
        
        BindingBase* binding = [[BindingBase alloc] initWithKensho:ken
                                                            target:btn
                                                              type:@"type"
                                                             value:self
                                                           context:context];
        weakBinding = binding;
        [binding unbind];
    }
    
    
    XCTAssertNil(weakBinding, @"Object was not released");
    XCTAssertNil(weakContext, @"Object was not released");
    XCTAssertNil(weakButton, @"Object was not released");
}

#pragma mark - Test Mocks

- (void) addKenshoObserver:(NSObject<Observer>*)observer
{
    [observers addObject:observer.weak];
}

- (void) removeKenshoObserver:(NSObject<Observer>*)observer
{
    [observers removeObject:observer.weak];
}

@end
