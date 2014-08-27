//
//  KenshoJsContext.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/20/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "Kensho.h"

@interface KenshoLuaWrapper : NSObject<Observer>

- (id) initWithKensho:(Kensho*)ken context:(id)context code:(NSString*)code;
- (NSObject*) evaluate:(NSString*)newCode;

@property (readonly) NSDictionary* parameters;

@end

/**
 *  Updates when the script is rerun
 */
@interface KenshoLuaParameterWrapper : NSObject<Observable>

@property (readonly) KenshoLuaWrapper* wrapper;
@property (readonly) NSString* parameterName;

@end
