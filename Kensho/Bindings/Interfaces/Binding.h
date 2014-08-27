//
//  Binding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObservableBase.h"

@class UIView;

@protocol Binding <Observer> 

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary;

@property (weak, readonly) Kensho* ken;
@property (weak, readonly) UIView* targetView;
@property (weak, readonly) NSObject<Observable>* targetValue;
@property (readonly) NSString* bindingType;
@property (weak, readonly) NSObject* context;
@property (readonly) NSDictionary* parameters;

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<Observable>*)value context:(NSObject*)context parameters:(NSDictionary*)parameters;
- (void) updateValue;
- (void) unbind;

@end
