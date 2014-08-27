//
//  ObservableAsString.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observable.h"

@protocol ObservableWritableString <Observable>

- (void) setStringValue:(NSString*)value;

@end