//
//  KenComputed.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenComputed.h"
#import "Kensho.h"
#import "NSObject+Observable.h"
#import "KenObservationTracking.h"

@interface KenComputed ()
{
    NSObject* (^_calculatorMethod)(KenComputed*);
    Kensho* ken;
    
    NSDictionary* observing;
}

@property (readonly, nonatomic) NSObject* liveValue;
@property (strong, nonatomic) id value;

@end

@implementation KenComputed

- (id) initWithKensho:(Kensho *)initialken
           calculator:(NSObject*(^)(KenComputed*))calculatorMethod
{
    if((self = [super init]))
    {
        _calculatorMethod = [calculatorMethod copy];
        ken = initialken;
        [self observe:ken];
        
        // But now, implement an observation on ourself!
        [self addObserver:self attribute:@"liveValue" context:@"value"];
        
        // set our initial value
        self.value = self.liveValue;
    }
    return self;
}

- (NSObject*) liveValue
{
    return self.calculatorMethod(self);
}


- (void)observable:(NSObject *)observableOwner updated:(NSString *)attributeName context:(NSString *)context
{
    // When our live value updates, assign it to the 'cached' property.
    // This allows for situations where expensive calls don't have to be invoked each time.
    if([attributeName isEqualToString:@"liveValue"] && [context isEqualToString:@"value"])
    {
        self.value = self.liveValue;
    }
}

- (void)observableDeallocated:(NSObject *)observableOwner context:(NSString *)context
{}

@end
