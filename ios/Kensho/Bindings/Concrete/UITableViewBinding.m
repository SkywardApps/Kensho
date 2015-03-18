//
//  UITableViewBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UITableViewBinding.h"
#import "Kensho.h"
#import "KenshoContext.h"
#import "Kensho+Protected.h"

@implementation UITableViewBinding

+ (void) registerFactoriesTo:(Kensho*)ken
{
    
    [BindingBase addFactoryNamed:@"foreach"
                           class:UITableView.class
                      collection:ken.bindingFactories
                          method:^(UITableView* view, NSString* type, NSObject<KenshoValueParameters>* observable, NSObject* context)
     {
         return [[UITableViewBinding alloc] initWithKensho:ken target:view type:type value:observable context:context];
     }];
}

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<KenshoValueParameters>*)value context:(NSObject *)context
{
    if((self = [super initWithKensho:ken target:target type:type value:value context:context]))
    {
        [(UITableView*)target setDataSource:self];
    }
    return self;
}

- (void) updateValue
{
    [(UITableView*)self.targetView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultValue count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<IObservable>* valueItem;
    NSEnumerator* enumerator = [self.resultValue objectEnumerator];
    for(int i = 0; i <= indexPath.row; ++i)
    {
        valueItem = [enumerator nextObject];
    }
    
    NSString* reuseIdentifier;
    
    @try
    {
        reuseIdentifier = [valueItem valueForKey:@"cellClass"];
    }
    @catch(NSException* exception)
    {
        reuseIdentifier = self.observedValue.parameters[@"cellClass"];
        if(reuseIdentifier == nil)
        {
            self.ken.errorMessage.value = @"The view model does not implement the required cellClass defining the cell view type";
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"koErrorCell"];
        }
    }
    
    UITableViewCell* cell = nil;;
    
    if([self.observedValue.parameters[@"prototype"] boolValue])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    
    if(cell != nil)
    {
        [self.ken removeBindingsForView:cell];
    }
    
    if(cell == nil)
    {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:reuseIdentifier
                                                          owner:nil
                                                        options:nil];
        
        cell = [ nibViews objectAtIndex: 0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    // apply bindings here
    KenshoContext* rootContext = [[KenshoContext alloc] initWithContext:valueItem parent:self.context];
    [self.ken bindToView:cell context:rootContext];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.observedValue.parameters[@"selected"] != nil)
    {
        NSObject<IObservable>* valueItem;
        NSEnumerator* enumerator = [self.resultValue objectEnumerator];
        for(int i = 0; i <= indexPath.row; ++i)
        {
            valueItem = [enumerator nextObject];
        }
        [self.context setValue:valueItem forKey:self.observedValue.parameters[@"selected"]];
    }
}

@end


@implementation UITableView (Kensho)

- (void) setDataBindForEach:(NSString *)dataBindForEach
{
    self.ken[@"foreach"] = dataBindForEach;
}

- (NSString *)dataBindForEach
{
    return self.ken[@"foreach"];
}

@end
