//
//  KenModel.m
//  Kensho
//
//  Created by Nicholas Elliott on 11/26/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenModel.h"
#import "Kensho.h"
#import "NSObject+Observable.h"

@implementation KenModel

- (id) initWithKensho:(Kensho*)ken
{
    // automatically wrap as a proxy!
    return [[super init] observe:ken];
}

@end
