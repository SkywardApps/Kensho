//
//  BindingBase.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Binding.h"
#import "IObservable.h"

@interface BindingBase : NSObject<Binding, IObserver>

@property (weak, readonly) Kensho* ken;
@property (weak, readonly) UIView* targetView;
@property (weak, readonly) NSObject<KenshoValueParameters>* observedValue;
@property (weak, readonly) id resultValue;

@property (readonly) NSString* bindingType;
@property (weak, readonly) NSObject* context;

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<KenshoValueParameters>*)value context:(NSObject*)context;

+ (void) addFactoryNamed:(NSString*)name class:(Class)class collection:(NSMutableDictionary*)bindingFactories method:(id)method;

@end
