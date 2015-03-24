//
//  AppDelegate.h
//  Sample
//
//  Created by Nicholas Elliott on 3/23/15.
//  Copyright (c) 2015 Skyward App Company, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Kensho/Kensho.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly) Kensho* ken;
@property (readonly) UIViewController* rootViewController;

@end

