//
//  Binding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class Kensho;
@protocol KenshoValueParameters;

@protocol Binding

+ (void) registerFactoriesTo:(Kensho*)ken;

@property (weak, readonly) Kensho* ken;
@property (weak, readonly) UIView* targetView;
@property (weak, readonly) NSObject<KenshoValueParameters>* observedValue;


@property (readonly) NSString* bindingType;
@property (weak, readonly) NSObject* context;

- (id) initWithKensho:(Kensho*)ken
               target:(UIView*)target
                 type:(NSString*)type
                value:(NSObject<KenshoValueParameters>*)value
              context:(NSObject*)context;

- (void) updateValue;

- (void) unbind;

@end
