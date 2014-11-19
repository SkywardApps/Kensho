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

@interface KenshoLuaWrapper : NSObject<IObserver>

- (id) initWithKensho:(Kensho*)ken context:(KenshoContext*)context code:(NSString*)code;
- (NSObject*) evaluate:(NSString*)newCode;

@property (readonly) NSDictionary* parameters;

@end

