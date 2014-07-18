//
//  ObservableNumber.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"
#import "ObservableAsNumber.h"

@interface ObservableNumber : ObservableBase<ObservableWritableNumber>

@property (nonatomic) NSNumber* numberValue;

@end
