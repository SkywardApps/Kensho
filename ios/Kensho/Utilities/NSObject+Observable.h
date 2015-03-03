//
//  ObservableProxy.h
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Kensho;
@protocol IObserver;

@interface NSObject (Observable)

- (id) observe:(Kensho*)ken;

#pragma mark - IObservable informal implementation
- (void) addObserver:(NSObject<IObserver>*)observer attribute:(NSString*)selfAttribute context:(NSString*)context;
- (void) removeObserver:(NSObject<IObserver>*)existingObserver attribute:(NSString*)selfAttribute context:(NSString*)existingContext;
@end
