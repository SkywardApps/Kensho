//
//  Observable.h
//  Once In A While
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Observable;
@protocol Observer;

@protocol Observer <NSObject>

- (void) observableUpdated:(NSObject<Observable>*)observable;

@end

@protocol CollectionObserver <Observer>

- (void) observable:(NSObject<Observable>*)observable added:(NSObject<Observable>*)observable forKey:(NSObject*)key;
- (void) observable:(NSObject<Observable>*)observable removed:(NSObject<Observable>*)observable fromKey:(NSObject*)key;

@end

@protocol Observable <NSObject>

- (void) observedBy:(NSObject<Observer>*)observer;
- (void) unobserve:(NSObject<Observer>*)observer;

@end



