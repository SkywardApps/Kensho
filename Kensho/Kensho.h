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
#import "ObservableAsNumber.h"
#import "ObservableAsString.h"
#import "ObservableAsEnumerator.h"

#import "ObservableNumber.h"
#import "ObservableString.h"
#import "ObservableArray.h"

#import "CalculatedObservableNumber.h"
#import "CalculatedObservableString.h"
#import "ProxyObservableArray.h"

@interface Kensho : NSObject

@property (readonly) NSObject<ObservableWritableString>* errorMessage;

- (void) applyBindings:(UIView*)rootView viewModel:(NSObject<Observable>*)model;

- (void) startTracking;
- (void) observableAccessed:(NSObject<Observable>*)observable;
- (NSMutableSet*) endTracking;

- (void) removeBindingsForView:(UIView*)view;

@end
