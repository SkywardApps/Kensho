//
//  CalculatedObservable.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"


@interface CalculatedObservable : ObservableBase<Observer>

- (void) startTracking;
- (void) endTracking;

@end
