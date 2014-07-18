//
//  UITableViewBinding.h
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindingBase.h"
#import "ObservableAsEnumerator.h"
#import <UIKit/UIKit.h>


@interface UITableViewBinding : BindingBase <UITableViewDataSource>

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<ObservableAsEnumerator>*)value context:(NSObject*)context;;

@property (weak, readonly) UITableView* targetView;
@property (weak, readonly) NSObject<ObservableAsEnumerator>* targetValue;

@end
