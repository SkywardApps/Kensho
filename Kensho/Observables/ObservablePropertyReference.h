//
//  ObservablePropertyReference.h
//  Kensho
//
//  Created by Nicholas Elliott on 2/19/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ObservablePropertyReference : NSObject

@property (readonly, strong, nonatomic) NSObject* owner;
@property (readonly, strong, nonatomic) NSString* propertyName;
@property (readonly, nonatomic) NSObject* value;

- (id) initWithOwner:(NSObject*)owner propertyName:(NSString*)name;

+ (NSObject*) unwrap:(NSObject*)value;

@end
