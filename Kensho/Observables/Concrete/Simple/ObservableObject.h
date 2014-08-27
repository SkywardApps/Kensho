//
//  ObservableObject.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/18/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Kensho/Kensho.h>

@interface ObservableObject : ObservableBase<ObservableWritableObject>

- (id) initWithKensho:(Kensho *)ken value:(NSObject*)value;

@property id objectValue;

@end
