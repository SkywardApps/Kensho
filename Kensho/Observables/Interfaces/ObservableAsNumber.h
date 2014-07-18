//
//  ObservableAsNumber.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObservableAsNumber <NSObject>

- (NSNumber*) numberValue;

@end


@protocol ObservableWritableNumber <ObservableAsNumber>

- (void) setNumberValue:(NSNumber*)value;

@end
