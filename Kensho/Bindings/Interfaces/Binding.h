//
//  Binding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observable.h"

@class UIView;

@protocol Binding <IObserver> 

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary;

@property (weak, readonly) Kensho* ken;
@property (weak, readonly) UIView* targetView;
@property (weak, readonly) NSObject* targetValue;
@property (readonly) NSString* bindingType;
@property (weak, readonly) NSObject* context;

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<IObservable>*)value context:(NSObject*)context;
- (void) updateValue;
- (void) unbind;

@end
