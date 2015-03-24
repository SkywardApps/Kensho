//
//  BindingBase.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "BindingBase.h"
#import <UIKit/UIKit.h>
#import "KenComputed.h"
#import "IObservable.h"
#import "KenshoLuaWrapper.h"
#import "NSObject+Observable.h"

@implementation BindingBase
@dynamic resultValue;
/**
 *  Interesting issue here
 *  We may get a binding of '42'
 *  We may get a binding of observable
 *  We may also get a binding of observableTest?observable1:observable2
 *  What this means is that we may have a value, an observable, or a computed that
 *  returns a value or observable.
 *  So we need to test for all three cases!?!?!
 */
- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<KenshoValueParameters>*)value context:(NSObject*)context
{
    if((self = [super init]))
    {
        _targetView = target;
        _observedValue = value;
        _bindingType = type;
        _ken = ken;
        _context = context;
        
        [self observe:_ken];
        
        if([_observedValue respondsToSelector:@selector(addObserver:attribute:context:)])
        {
            [_observedValue addObserver:self attribute:@"value" context:@"baseValue"];
            [_observedValue addObserver:self attribute:@"parameters" context:@"parameterValue"];
        }
        
        [self updateValue];
    }
    return self;
}

- (id)resultValue
{
    return self.observedValue.value;
}

- (void)observable:(NSObject *)observableOwner updated:(NSString *)attributeName context:(NSString *)context
{
    [self updateValue];
}

- (void) updateValue
{
    @throw [NSException exceptionWithName:@"NotYetImplemented"
                                   reason:[NSString stringWithFormat:@"Class %@ must overload and implement updateValue", NSStringFromClass(self.class)]
                                 userInfo:nil];
}

+ (void) addFactoryNamed:(NSString*)name
                   class:(Class)class
              collection:(NSMutableDictionary*)bindingFactories
                  method:(id)method
{
    id<NSCopying> classKey = (id)class;
    if(bindingFactories[classKey] == nil)
    {
        bindingFactories[classKey] = [NSMutableDictionary dictionary];
    }
    
    bindingFactories[classKey][name] = method;
}

@end
