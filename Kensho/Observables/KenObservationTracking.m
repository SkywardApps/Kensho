//
//  ObservableProxyTracking.m
//  Kensho
//
//  Created by Nicholas Elliott on 12/2/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenObservationTracking.h"
#import "WeakProxy.h"
#import "Kensho.h"


/**
 *  @todo This should be become the central dispatch and observable registration for 
 * and object.  When another object observes the owned object, this should track it and 
 * dispatch the relevant update.
 * So updates can start with KVO, but immediately enter into the Tracking mechanism and
 * are then disseminated via our own communication mechanism.
 *
 * This allows us to write an explicit object to intercept things like 'change' events 
 * at the binding level, otherwise there's no action ever performed!
 */
@interface KenObservationTracking  ()
{
    // When an attribute is accessed, we let Kensho know
    // We then track what other attributes on self are accessed, and what
    // other entities via our observable system
    
    // When done, we have to register for any update on ourself via KVO,
    // and any children via the observation system.
    
    // When we get notification that an attribute is accessed on ourselves,
    // we dispatch up the chain via the observation system
    
    // When we get notification that a child observable is changed, we also
    // dispatch up the chain via the observation system
    
    // We need a category method that allows anyone implementing the IObserver
    // interface to register on an object for a property.  This is a
    // weak-in-both-directions relationship!  But, this also allows us to send a
    // object-now-deallocting message to the receiver - however this is a bit weird
    // because they have to use an unsafe pointer at that point to do anything!
    
    
    /**
     * This map lists our attributes to objects who are observing them.
     * The target object is an array 2-element arrays, of
     * @[weak proxy to object, context (usually string of the dependent attribute)
     */
    NSMutableDictionary* attributeObserverMap;
    
    /**
     * This map lists our attributes to objects and their properties that they
     * depend on.
     * The key is the attribute name, and the value is a 2-element array of
     * @[weak proxy to object, dependant attribute name]
     */
    NSMutableDictionary* attributeDependencyMap;
    
    NSSet* attributeList;
    
    __weak Kensho* ken;
    id target;
}

@end

void* KenObservationTrackingInternalObservationKey = &KenObservationTrackingInternalObservationKey;

@implementation KenObservationTracking

- (id) initWithTarget:(id)initialTarget kensho:(Kensho*)initialKen attributes:(NSSet*)attributes
{
    if((self = [super init]))
    {
        ken = initialKen;
        attributeList = attributes;
        
        // Take a weak (but allowed to be unsafe) proxy reference
        target = [initialTarget weak];
        
        attributeObserverMap = [NSMutableDictionary dictionary];
        attributeDependencyMap = [NSMutableDictionary dictionary];
        
        // Register for all updates to our own attributes.  We'll then pass them on as needed.
        for(NSString* attribute in attributeList)
        {
            [target addObserver:self
                     forKeyPath:attribute
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                        context:KenObservationTrackingInternalObservationKey];
            
            attributeObserverMap[attribute] = [NSMutableArray array];
        }
    }
    return self;
}

#pragma mark - Internal dispatch implementation

/**
 *  This is invoked when a READ is issued to a property.
 *
 *  @param selfAttribute The name of the attribute being read
 */
- (void) startTrackingAttribute:(NSString*)selfAttribute
{
    // Clear all dependencies for this attribute, we'll update afterwards.
    /**
     @todo Is there a way to handle this better? It would be nice to only de-register items we don't
     observe anymore, and leave in place any we do.
     */
    for(NSArray* dependancy in attributeDependencyMap[selfAttribute])
    {
        NSObject<IObservable>* dependant = [dependancy[0] strong];
        NSString* targetAttribute = dependancy[1];
        [dependant removeObserver:self attribute:targetAttribute context:selfAttribute];
    }
    
    // Let the kensho object know this property was accessed
    [ken key:selfAttribute accessedOn:target];
    
    // Now start tracking what this attribute, if any, accesses.
    [ken startTracking];
}

/**
 *  This is invoked after a READ has resolved for a property
 *
 *  @param selfAttribute The name of the attribute being read
 */
- (void) endTrackingAttribute:(NSString*)selfAttribute
{
    NSSet* newlyObservedExternal = [ken endTracking];
    
    // Register to observe new dependencies!
    attributeDependencyMap[selfAttribute] = [newlyObservedExternal copy];
    for(NSArray* dependancy in attributeDependencyMap[selfAttribute])
    {
        NSObject<IObservable>* dependant = [dependancy[0] strong];
        NSString* targetAttribute = dependancy[1];
        if(!([targetAttribute isEqualToString:selfAttribute] && dependant == [target strong]))
        {
            [dependant addObserver:self attribute:targetAttribute context:selfAttribute];
        }
    }
}

/**
 *  This is invoked when an attribute on self is changed.  We will use this
 *  to alert other objects.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context != KenObservationTrackingInternalObservationKey)
    {
        return;
    }
    
    if([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]])
    {
        return;
    }
    
    NSString* selfAttribute = keyPath;
    
    // trigger any dependant observers
    for(NSArray* dependant in [attributeObserverMap[selfAttribute] copy])
    {
        NSObject<IObserver>* observer = [dependant[0] strong];
        NSString* context = dependant[1];
        [observer observable:target updated:selfAttribute context:context];
    }
}

- (void)dealloc
{
    for(NSString* selfAttribute in attributeList)
    {
        // First, unregister for updates to this attribute.
        // We have to use an unsafe pointer here because weak pointers
        // have already become nil!
        [[target unsafe] removeObserver:self
                             forKeyPath:selfAttribute
                                context:KenObservationTrackingInternalObservationKey];
        
        // Now, alert all dependencies that we're going away!
        for(NSArray* dependant in attributeObserverMap[selfAttribute])
        {
            NSObject<IObserver>* observer = [dependant[0] strong];
            NSString* context = dependant[1];
            [observer observableDeallocated:[target unsafe] context:context];
        }
    }
}

#pragma mark - IObserver

/**
 *  This is invoked when an attribute we're watching (could be on ourself, or another object)
 *  changes.
 */
- (void) observable:(NSObject*)observableOwner updated:(NSString*)attributeName context:(NSString*)context
{
    NSString* selfAttribute = context;
    
    // We now need to dispatch off the repercussions
    for(NSArray* dependant in [attributeObserverMap[selfAttribute] copy])
    {
        NSObject<IObserver>* observer = [dependant[0] strong];
        NSString* context = dependant[1];
        [observer observable:target updated:selfAttribute context:context];
    }
    
    // we now need to reasses ourselves, as it is possible that the dependency chart has changed!
    // we can do this with a simple property access
    [target valueForKey:selfAttribute];
}

- (void) observableDeallocated:(NSObject*)observableOwner context:(NSString*)context
{
    /**
     @todo We should clean up our observation of this object.  Do we even need to? The next update will remove it anyway? Although
     see the todo for startTracking.
     */
}

#pragma mark - IObservable

- (void) addObserver:(NSObject<IObserver>*)observer attribute:(NSString*)selfAttribute context:(NSString*)context
{
    [attributeObserverMap[selfAttribute] addObject:@[observer.weak, context]];
}

- (void) removeObserver:(NSObject<IObserver>*)existingObserver attribute:(NSString*)selfAttribute context:(NSString*)existingContext
{
    /**
     @todo This is very slow, currently. It is a linear crawl over all observers of the given attribute.  In
     small cases this is fine, in complex cases this could be a big issue
     */
    for(int i = 0; i < [attributeObserverMap[selfAttribute] count]; ++i)
    {
        NSArray* dependant = attributeObserverMap[selfAttribute][i];
        NSObject<IObserver>* observer = [dependant[0] strong];
        NSString* context = dependant[1];
        //[observer observable:target updated:selfAttribute context:context];
        if(observer.strong == existingObserver.strong && [context isEqualToString:existingContext])
        {
            [attributeObserverMap[selfAttribute] removeObjectAtIndex:i];
            --i;
        }
    }
}



@end
