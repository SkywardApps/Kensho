//
//  ObservableProxyTracking.h
//  Kensho
//
//  Created by Nicholas Elliott on 12/2/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IObservable.h"

@class Kensho;
@interface KenObservationTracking : NSObject<IObserver, IObservable>

- (id) initWithTarget:(id)initialTarget kensho:(Kensho*)initialKen attributes:(NSSet*)attributes;
- (void) startTrackingAttribute:(NSString*)selfAttribute;
- (void) endTrackingAttribute:(NSString*)selfAttribute;

@end
