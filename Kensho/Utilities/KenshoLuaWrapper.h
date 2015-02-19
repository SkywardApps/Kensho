//
//  KenshoJsContext.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/20/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "Kensho.h"
#import "KenshoContext.h"
#import "KenComputed.h"
#import "IObservable.h"

@interface KenshoLuaWrapper : KenComputed<KenshoValueParameters>

- (id) initWithKensho:(Kensho*)ken context:(KenshoContext*)context code:(NSString*)code;
- (NSObject*) evaluate:(NSString*)newCode;

@property (nonatomic, readonly) NSDictionary* parameters;
@property (nonatomic, readonly) NSString* code;

@end


@interface ObservablePropertyReference : NSObject

@property (readonly, strong, nonatomic) NSObject* owner;
@property (readonly, strong, nonatomic) NSString* propertyName;
@property (readonly, nonatomic) NSObject* value;

- (id) initWithOwner:(NSObject*)owner propertyName:(NSString*)name;

+ (NSObject*) unwrap:(NSObject*)value;

@end
