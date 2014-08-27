//
//  Observable.h
//  Kensho
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

- (void) observable:(NSObject<Observable>*)collection
              added:(NSObject<Observable>*)item
             forKey:(NSObject*)key;
- (void) observable:(NSObject<Observable>*)collection
            removed:(NSObject<Observable>*)item
            fromKey:(NSObject*)key;

@end

/**
 *  The Observable protocol allows any object to be 'observed' in the Kensho system.
 *
 *  Observables must be a Number, String, List, Map, or generic Object.  Lists and Maps are treated as 'collections'.
 *  Any observable can be observed by delegates implementing the Observer protocol, and collections can emit additional
 *  events to delegates implementing the CollectionObserver protocol.
 *
 *  All observables must return an object from the 'value' property.
 */
@protocol Observable <NSObject>

- (void) addKenshoObserver:(NSObject<Observer>*)observer;
- (void) removeKenshoObserver:(NSObject<Observer>*)observer;

@property (readonly) id value;
@property (readonly) NSString* stringValue;
@property (readonly) NSNumber* numberValue;
@property (readonly) NSObject* objectValue;

@property (readonly) BOOL isNumber;
@property (readonly) BOOL isString;
@property (readonly) BOOL isObject;
@property (readonly) BOOL isList;
@property (readonly) BOOL isMap;

@property (readonly) BOOL isCollection;

@end



