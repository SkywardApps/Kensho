//
//  BindingBase.h
//  Once In A While
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Binding.h"

@interface BindingBase : NSObject<Binding>

@property (weak, readonly) Kensho* ken;
@property (weak, readonly) UIView* targetView;
@property (weak, readonly) NSObject<Observable>* targetValue;
@property (readonly) NSString* bindingType;
@property (weak, readonly) NSObject* context;

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<Observable>*)value context:(NSObject*)context;

@end
