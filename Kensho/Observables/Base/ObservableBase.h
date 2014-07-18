//
//  ViewModelObject.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Observable.h"

@class Kensho;

@interface ObservableBase : NSObject<Observable>

@property (weak, readonly) Kensho* ken;

- (id) initWithKensho:(Kensho*)ken;

- (void) observedBy:(NSObject<Observer>*)observer;
- (void) triggerChangeEvent;

@end
