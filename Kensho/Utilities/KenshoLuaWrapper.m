//
//  KenshoJsContext.m
//  Kensho
//
//  Created by Nicholas Elliott on 7/20/14.
//  Copyright (c) 2014 Skyward App Company, LLC. All rights reserved.
//

#import "KenshoLuaWrapper.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#import "Observable.h"


@interface KenshoLuaWrapper ()
{
    id context;
    NSMutableDictionary* parameters;
    NSMutableDictionary* internalParameters;
    NSString* code;
    Kensho* ken;
}

@property (readwrite) NSMutableDictionary* parameters;

@end


int lookupKey(lua_State* L);
int pushValue(lua_State* L, NSObject* value);


int pushValue(lua_State* L, NSObject* value)
{
    if([value isKindOfClass:NSNumber.class])
    {
        lua_pushnumber(L, [(NSNumber*)value doubleValue]);
        if(!lua_isnumber(L, -1))
        {
            NSLog(@"Stack is wrong");
        }
        return 1;
    }
    else if([value isKindOfClass:NSString.class])
    {
        lua_pushstring(L, [(NSString*)value UTF8String]);
        return 1;
    }
    else if([value conformsToProtocol:@protocol(Observable)]
            && ![(NSObject<Observable>*)value isCollection])
    {
        NSObject<Observable>* obs = (NSObject<Observable>*)value;
        NSObject* result = obs.value;
        return pushValue(L, result);
    }
    else if([value isKindOfClass:NSObject.class])
    {
        // do something crazy here to allow key descent (view.frame.width)??
        NSObject* __weak *userdata = (NSObject* __weak *)lua_newuserdata(L, sizeof(NSObject*));
        (*userdata) = value;
        
        lua_createtable(L, 0, 1);
        lua_pushlightuserdata(L, (__bridge void *)(value));
        lua_setfield(L, -2, "__self");
        
        lua_createtable(L, 0, 1);
        lua_pushstring(L, "__index");
        lua_pushcfunction(L, lookupKey);
        lua_settable(L, -3);
        
        //-- set global index callback hook
        lua_setmetatable(L, -2);
        
        if(!lua_istable(L, -1))
        {
            NSLog(@"Stack is wrong");
        }
        return 1;
    }
    
    return 0;
}

int lookupKey(lua_State* L)
{
    // Stack is [tabble, key]
    if(!lua_isstring(L, -1))
    {
        return 0;
    }
    
    if(!lua_istable(L, -2))
    {
        return 0;
    }
    
    // Get the pointer to the context object
    lua_getfield(L, -2, "__self");
    id target = (__bridge id)(lua_touserdata(L, -1));
    if(target == nil)
    {
        return 0;
    }
    
    const char* nameRequest = lua_tostring(L, -2);
    if(nameRequest == NULL)
    {
        return 0;
    }
    
    NSString* propertyName = [NSString stringWithUTF8String:nameRequest];
    NSObject* value = [target valueForKey:propertyName];
    if(value == nil)
    {
        return 0;
    }
    
    return pushValue(L, value);
}

/**
 *  This is executed when the LUA subsystem attempts to assign data to a new index.
 * 
 *  This will probably only be executed when our implicit result is assigned.  Originally each
 *  parameter was being assigned at the top level, but now we'll get a 'table' back with the result data.
 *
 *  @param L The LUA subsystem
 *
 *  @return 0 if not handled (and nil is used in the LUA subsystem)
 */
int lookupNewKey(lua_State* L)
{
    // Stack is [table, key, value]
    
    // Verify that the key is a string
    if(!lua_isstring(L, -2))
    {
        return 0;
    }
    
    // Make sure that the context is a table.  This should actually be the global table.
    if(!lua_istable(L, -3))
    {
        return 0;
    }
    
    // Make sure the key is a valid string too!
    const char* nameRequest = lua_tostring(L, -2);
    if(nameRequest == NULL)
    {
        return 0;
    }
    
    // Get the pointer to the context table (the global table here)
    // And then get it's __wrapper object, which points to the owning KenshoLuaWrapper.
    lua_getfield(L, -3, "__wrapper");
    id target = (__bridge id)(lua_touserdata(L, -1));
    if(target == nil)
    {
        return 0;
    }
    
    // Convert to an NSString and start navigating the Objective-C side
    NSString* propertyName = [NSString stringWithUTF8String:nameRequest];
    KenshoLuaWrapper* wrapper = target;
    NSObject* value = nil;
    
    // Now figure out the datatype of the assignement and get the data out
    if(lua_isboolean(L, -2))
    {
        value = @(lua_toboolean(L, -2));
    }
    else if(lua_isnumber(L, -2))
    {
        value = @(lua_tonumber(L, -2));
    }
    else if(lua_isstring(L, -2))
    {
        const char* tempString = lua_tostring(L, -2);
        value = [NSString stringWithUTF8String:tempString];
    }
    else if(lua_istable(L, -2))
    {
        // This is a bit of a special case here.  We assume this is a wrapper for an NSObject.
        // This could actually be a new table, in which case this will fail.
        lua_getfield(L, -2, "__self");
        value = (__bridge id)(lua_touserdata(L, -1));
    }
    else
    {
        return 0;
    }
    [wrapper.parameters setValue:value forKey:propertyName];
    
    return 1;
}

@implementation KenshoLuaWrapper

@synthesize parameters=_internalParameters;

- (id) initWithKensho:(Kensho *)initken context:(id)initcontext code:(NSString *)initcode
{
    if((self = [super init]))
    {
        ken = initken;
        context = initcontext;
        code = initcode;
        parameters = [NSMutableDictionary dictionary];
        
        [self evaluate];
    }
    return self;
}

- (NSObject*) evaluate:(NSString*)newCode
{
    code = newCode;
    return [self evaluate];
}

- (NSObject*) evaluate
{
    [ken startTracking];
    
    @try
    {
        lua_State* L = (lua_State *) luaL_newstate();
        luaL_openlibs(L);
        
        lua_pushlightuserdata(L, (__bridge void *)(context));
        lua_setglobal(L, "__self");
        
        lua_pushlightuserdata(L, (__bridge void *)(self));
        lua_setglobal(L, "__wrapper");
        
        //-- get global environment table from registry
        lua_pushglobaltable(L);
        
        //-- create table containing the hook details
        lua_newtable(L);
        lua_pushstring(L, "__index");
        lua_pushcfunction(L, lookupKey);
        lua_settable(L, -3);
        
        lua_pushstring(L, "__newindex");
        lua_pushcfunction(L, lookupNewKey);
        lua_settable(L, -3);
        
        //-- set global index callback hook
        lua_setmetatable(L, -2);
        
        //-- remove the global environment table from the stack
        lua_pop(L, 1);
        
        NSString* embeddedString = [NSString stringWithFormat:@"__final = %@;", code];
        
        /* run the test script */
        luaL_loadstring(L, embeddedString.UTF8String);
        if (0 == lua_pcall(L, 0, 1, 0))
        {
            return parameters[@"__final"];
        }

        return nil;
    }
    @finally
    {
        NSSet* tracklist = [ken endTracking];
        for(NSObject<Observable>* trackitem in tracklist)
        {
            [trackitem addKenshoObserver:self];
        }
        
        // now update all of our parameters / observables
    }
}


- (void) observableUpdated:(NSObject<Observable>*)observable
{
    [self evaluate];
}

- (void) observable:(NSObject<Observable>*)collection
              added:(NSObject<Observable>*)item
             forKey:(NSObject*)key
{
    
}

- (void) observable:(NSObject<Observable>*)collection
            removed:(NSObject<Observable>*)item
            fromKey:(NSObject*)key
{
    
}

@end
