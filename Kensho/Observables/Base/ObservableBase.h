//
//  ViewModelObject.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observable.h"

@class Kensho;

@interface ObservableBase : NSObject<Observable>

@property (weak, readonly) Kensho* ken;
@property (readonly) NSSet* observers;

- (id) initWithKensho:(Kensho*)ken;
- (id) initWithKensho:(Kensho*)ken value:(id)value;
- (void) triggerChangeEvent;

#pragma mark - Observable Protocol

- (void) addKenshoObserver:(NSObject<Observer>*)observer;
- (void) removeKenshoObserver:(NSObject<Observer>*)observer;

@property (atomic) id value;
@property (readonly) NSString* stringValue;
@property (readonly) NSNumber* numberValue;
@property (readonly) NSObject* objectValue;

@property (readonly) BOOL isNumber;
@property (readonly) BOOL isString;
@property (readonly) BOOL isObject;
@property (readonly) BOOL isList;
@property (readonly) BOOL isMap;

@property (readonly) BOOL isCollection;

#pragma mark -

@end
