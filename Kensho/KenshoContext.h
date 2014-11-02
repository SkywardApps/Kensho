//
//  KenshoContext.h
//  Kensho
//
//  Created by Nicholas Elliott on 8/27/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A wrapper for a 'context' for binding.  
 *
 *  Creates a stack of contexts, with a parent and a direct link to the root of the stack.
 */
@interface KenshoContext : NSObject

- (id) initWithContext:(id)context parent:(KenshoContext*)parent;

/**
 *  The context wrapper at the base of the stack.  Self if there is no parent.
 */
@property (readonly) KenshoContext* root;

/**
 *  The context wrapper one step below this one in the stack.  May be nil.
 */
@property (readonly) KenshoContext* parent;

/**
 *  The actual object that is the context for the binding.
 */
@property (readonly) id context;


/**
 * Access to to viewmodel OR self if prefixed with a $
 */
- (id)valueForKey:(NSString *)key;

@end
