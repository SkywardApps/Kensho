//
//  Kensho.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/17/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Include anything that should be included automatically in the library
#import "UIView+Kensho.h"

#import "Observable.h"
#import "ObservableArray.h"

#import "Computed.h"
#import "ComputedArray.h"

/**
 *  The core object for binding and updating.
 *
 *  There may be multiple instances of kensho in an application, but events and tracking will
 * _not_ propagate between them.  Typically you'd only want one instance for an app.
 */
@interface Kensho : NSObject

/**
 *  A helper method to 'unwrap' a value from an observable or value.
 *
 *  If the passed in object is a value type, it simply returns it.  If it implements the IObservable protocol, it will
 *  return the observed value.
 *
 *  @param object An object to get the value from.
 *
 *  @return The value of the object or its observed value.
 */
+ (id) unwrapObservable:(id)object;

/**
 *  A basic observable for error tracking
 */
@property (readonly) NSObject<IWritableObservable>* errorMessage;

/**
 *  Apply binding to a view tree starting at the view model for context.
 *
 *  @param rootView The view owning the subviews to bind.
 *  @param model    The object collecting properties to be bound to.
 */
- (void) applyBindings:(UIView*)rootView viewModel:(id)model;

/**
 *  Remove any and all bindings applied to a view.
 *
 *  Does not automatically remove bindings from subviews.
 *
 *  @param view The view to process and remove bindings from.
 */
- (void) removeBindingsForView:(UIView*)view;


#pragma mark - Internal processes
/**
 *  Used internally to track which observables are read from to create the dependancy tree.
 */
- (void) startTracking;

/**
 *  Used internally to denote that an observable was read from.
 *
 *  @param observable The observable object that was accessed.
 */
- (void) observableAccessed:(NSObject<IObservable>*)observable;

/**
 *  Used internally to end tracking observables.
 *
 *  @return The set of observables that have been accessed since startTracking was called.
 */
- (NSSet*) endTracking;


@end
