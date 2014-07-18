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

#import "Observables/Interfaces/Observable.h"
#import "Observables/Interfaces/ObservableAsNumber.h"
#import "Observables/Interfaces/ObservableAsString.h"
#import "Observables/Interfaces/ObservableAsEnumerator.h"

#import "Observables/Concrete/Simple/ObservableNumber.h"
#import "Observables/Concrete/Simple/ObservableString.h"
#import "Observables/Concrete/Simple/ObservableArray.h"

#import "Observables/Concrete/Calculated/CalculatedObservableNumber.h"
#import "Observables/Concrete/Calculated/CalculatedObservableString.h"
#import "Observables/Concrete/Calculated/ProxyObservableArray.h"

@interface Kensho : NSObject

@property (readonly) NSObject<ObservableWritableString>* errorMessage;

- (void) applyBindings:(UIView*)rootView viewModel:(NSObject<Observable>*)model;

- (void) startTracking;
- (void) observableAccessed:(NSObject<Observable>*)observable;
- (NSMutableSet*) endTracking;

- (void) removeBindingsForView:(UIView*)view;

@end
