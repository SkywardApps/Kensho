//
//  UITableViewBinding.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/14/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "UITableViewBinding.h"
#import "Kensho.h"

@implementation UITableViewBinding

+ (void) registerFactoriesTo:(NSMutableDictionary*)dictionary
{
    
}

- (id) initWithKensho:(Kensho*)ken target:(UIView*)target type:(NSString*)type value:(NSObject<IObservable>*)value context:(NSObject *)context
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
    return [[Kensho unwrapObservable:self.finalValue] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<IObservable>* valueItem;
    NSEnumerator* enumerator = [self.finalValue objectEnumerator];
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
        self.ken.errorMessage.value = @"The view model does not implement the required cellClass defining the cell view type";
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"koErrorCell"];
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
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
    [self.ken applyBindings:cell viewModel:valueItem];
    
    return cell;
}

@end
