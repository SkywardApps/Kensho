//
//  ObservableString.h
//  Once In A While
//
//  Created by Nicholas Elliott on 7/13/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "ObservableBase.h"
#import "ObservableAsString.h"

@interface ObservableString : ObservableBase<ObservableWritableString>

@property (nonatomic) NSString* stringValue;

@end
