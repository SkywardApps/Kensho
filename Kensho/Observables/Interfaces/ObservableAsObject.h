//
//  ObservableAsObject.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObservableWritableObject <Observable>

- (void) setObjectValue:(id)value;

@end