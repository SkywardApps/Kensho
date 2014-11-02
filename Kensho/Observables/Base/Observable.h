//
//  ViewModelObject.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IObservable.h"

#pragma mark - Predeclarations

@class Kensho;

#pragma mark -

/**
 *  Our base, concrete observable class.
 *
 *  Implements the IObservable protocol to completion, and can store any data type.  Uses basic reflection
 *  to report its data type - ie if it is a string or number, returns as such, otherwise returns as an object.
 */
@interface Observable : NSObject<IWritableObservable>

@property (weak, readonly) Kensho* ken;
@property (readonly) NSSet* observers;

/**
 *  Basic constructor
 *
 *  @param ken <#ken description#>
 *
 *  @return <#return value description#>
 */
- (id) initWithKensho:(Kensho*)ken;

/**
 *  Constructor with an initial value
 *
 *  @param ken   <#ken description#>
 *  @param value <#value description#>
 *
 *  @return <#return value description#>
 */
- (id) initWithKensho:(Kensho*)ken value:(id)value;

/**
 *  Public method to trigger a change notification.
 */
- (void) triggerChangeEvent;

#pragma mark - Implement Observable Protocol

- (void) addKenshoObserver:(NSObject<IObserver>*)observer;
- (void) removeKenshoObserver:(NSObject<IObserver>*)observer;

@property (atomic) id value;

@property (readonly) NSString* stringValue;
@property (readonly) NSNumber* numberValue;
@property (readonly) NSObject* objectValue;

@property (readonly) BOOL isNull;
@property (readonly) BOOL isNumber;
@property (readonly) BOOL isString;
@property (readonly) BOOL isObject;
@property (readonly) BOOL isList;
@property (readonly) BOOL isMap;

@property (readonly) BOOL isCollection;

#pragma mark -

@end
