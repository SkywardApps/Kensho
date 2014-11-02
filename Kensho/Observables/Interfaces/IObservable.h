//
//  Observable.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IObservable;
@protocol IObserver;

@protocol IObserver <NSObject>

- (void) observableUpdated:(NSObject<IObservable>*)observable;

@end

@protocol ICollectionObserver <IObserver>

- (void) observable:(NSObject<IObservable>*)collection
              added:(NSObject<IObservable>*)item
             forKey:(NSObject*)key;

- (void) observable:(NSObject<IObservable>*)collection
            removed:(NSObject<IObservable>*)item
            fromKey:(NSObject*)key;

@end

/**
 *  The IObservable protocol allows any object to be 'observed' in the Kensho system.  This is a read-only value.
 *
 *  Observables must be a Number, String, List, Map, or generic Object.  Lists and Maps are treated as 'collections'.
 *  Any observable can be observed by delegates implementing the Observer protocol, and collections can emit additional
 *  events to delegates implementing the CollectionObserver protocol.
 *
 *  All observables must return an object from the 'value' property.
 */
@protocol IObservable <NSObject>

- (void) addKenshoObserver:(NSObject<IObserver>*)observer;
- (void) removeKenshoObserver:(NSObject<IObserver>*)observer;

@property (readonly) id value;
@property (readonly) NSString* stringValue;
@property (readonly) NSNumber* numberValue;
@property (readonly) NSObject* objectValue;

@property (readonly) BOOL isNull;
@property (readonly) BOOL isNumber;
@property (readonly) BOOL isString;
@property (readonly) BOOL isObject;
@property (readonly) BOOL isList;
@property (readonly) BOOL isMap;

@property (readonly) BOOL isCollection;

@end

/**
 *  This extention to the IObservable protocol allows writing to an observable value.
 */
@protocol IWritableObservable <IObservable>

@property id value;

@end



