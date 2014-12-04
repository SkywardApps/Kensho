//
//  IObservable.h
//  Kensho
//
//  Created by Nicholas Elliott on 12/3/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IObserver <NSObject>
- (void) observable:(NSObject*)observableOwner updated:(NSString*)attributeName context:(NSString*)context;
- (void) observableDeallocated:(NSObject*)observableOwner context:(NSString*)context;
@end

@protocol IObservable <NSObject>
- (void) addObserver:(NSObject<IObserver>*)observer attribute:(NSString*)attribute context:(NSString*)context;
- (void) removeObserver:(NSObject<IObserver>*)observer attribute:(NSString*)attribute context:(NSString*)context;
@end


@protocol KenshoValueParameters <IObservable>
@property (nonatomic, readonly) NSDictionary* parameters;
@property (nonatomic, readonly) NSObject* currentValue;
@end

