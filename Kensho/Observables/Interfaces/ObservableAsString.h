//
//  ObservableAsString.h
//  Once In A While
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observable.h"

@protocol ObservableAsString <Observable>

- (NSString*) stringValue;

@end

@protocol ObservableWritableString <ObservableAsString>

- (void) setStringValue:(NSString*)value;

@end