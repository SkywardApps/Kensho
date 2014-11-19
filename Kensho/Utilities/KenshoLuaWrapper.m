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

/**
 Test cases:
 
 basic assignment of an observable:
    text=mytext
 
 assignment of a manipulation
    height=baseHeight * 100
 
 assignment of a compound object
    style={background=colors.blue, color=colors.red}
 
 multiple assignments
    text=mytext, height=baseHeight*100, style={background=colors.blue, color=colors.red}
 
 assignment within a foreach from the root, and from the parent
    text=$parent.mytext
    text=$root.mytext
 
 The above probably means we need a KenshoContext that wraps the context object, rather than just passing the 
 context object around bare like we do now.
 
 Ok, so this is a little different because we have multiple key-values, unlike knockout which is data-bind="values"
 So we want each binding to have two options - 
    a single value, eg. "text" "mytext"
    a config object, eg. "foreach" "{objects=myobjects, view=celltype}"
 
 The question is, do we:
    immediately translate all lua values full depth into NSObject versions and discard the original, or
    create LuaWrappers for each value type that late-binds.
    Since each value should be used, there's probably no use in late binding.
 */

@interface KenshoLuaWrapper ()
{
    // The kensho context object
    KenshoContext* context;
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
    else if([value isKindOfClass:NSObject.class])
    {
        if([value conformsToProtocol:@protocol(IObservable)])
        {
            NSObject<IObservable>* obs = (NSObject<IObservable>*)value;
            [obs value]; // access the value.  We don't do anything with it, but that does notify
            // any tracking that it was accessed so this calculated wrapper knows there is a
            // dependency
        }
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

NSObject* popValue(lua_State* L, int stackLevel)
{
    // Now figure out the datatype of the assignement and get the data out
    if(lua_isboolean(L, stackLevel))
    {
        return @(lua_toboolean(L, stackLevel));
    }
    else if(lua_isnumber(L, stackLevel))
    {
        return  @(lua_tonumber(L, stackLevel));
    }
    else if(lua_isstring(L, stackLevel))
    {
        const char* tempString = lua_tostring(L, stackLevel);
        return [NSString stringWithUTF8String:tempString];
    }
    else if(lua_istable(L, stackLevel))
    {
        // This is a bit of a special case here.  We assume this is a wrapper for an NSObject.
        // This could actually be a new table, in which case this will fail.
        lua_getfield(L, stackLevel, "__self");
        NSObject* value = (__bridge id)(lua_touserdata(L, -1));
        if(value == nil)
        {
            
            // We'll create an NSDictionary wrapper here
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
            
            while (lua_next(L, stackLevel-1) != 0) {
                /* uses 'key' (at index -2) and 'value' (at index -1) */
                printf("%s\n", lua_typename(L, lua_type(L, -2)));
                if(lua_isstring(L, -2))
                {
                    const char* tempString = lua_tostring(L, -2);
                    printf("%s\n", tempString);
                    
                }
                // Make sure the key is a valid string too!
                const char* nameRequest = lua_tostring(L, -2);
                if(nameRequest == NULL)
                {
                    return 0;
                }
                
                NSObject* subvalue = popValue(L, -1);
                dictionary[[NSString stringWithUTF8String:nameRequest]] = subvalue;
                
                /* removes 'value'; keeps 'key' for next iteration */
                lua_pop(L, 1);
                printf("%s\n", lua_typename(L, lua_type(L, -1)));
                if(lua_isstring(L, -1))
                {
                    const char* tempString = lua_tostring(L, -1);
                    printf("%s\n", tempString);
                    
                }
            }
            
            value = [NSDictionary dictionaryWithDictionary:dictionary];
        }
        printf("%s\n", lua_typename(L, lua_type(L, -1)));
        if(lua_isstring(L, -1))
        {
            const char* tempString = lua_tostring(L, -1);
            printf("%s\n", tempString);
            
        }
        return value;
    }
    
    return nil;
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
    lua_pop(L, 1);
    if(target == nil)
    {
        return 0;
    }
    
    // Convert to an NSString and start navigating the Objective-C side
    NSString* propertyName = [NSString stringWithUTF8String:nameRequest];
    KenshoLuaWrapper* wrapper = target;
    NSObject* value = nil;
    
    value = popValue(L, -1);
    // Ok, we save this value to the 'parameters' object
    [wrapper.parameters setValue:value forKey:propertyName];
    
    return 1;
}

@implementation KenshoLuaWrapper

- (id) initWithKensho:(Kensho *)initken context:(id)initcontext code:(NSString *)initcode
{
    if((self = [super init]))
    {
        ken = initken;
        context = initcontext;
        code = initcode;
        _parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
        
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
            return _parameters[@"__final"];
        }

        return nil;
    }
    @finally
    {
        NSSet* tracklist = [ken endTracking];
        for(NSObject<IObservable>* trackitem in tracklist)
        {
            [trackitem addKenshoObserver:self];
        }
        
        // now update all of our parameters / observables
    }
}


- (void) observableUpdated:(NSObject<IObservable>*)observable
{
    [self evaluate];
}

- (void) observable:(NSObject<IObservable>*)collection
              added:(NSObject<IObservable>*)item
             forKey:(NSObject*)key
{
    
}

- (void) observable:(NSObject<IObservable>*)collection
            removed:(NSObject<IObservable>*)item
            fromKey:(NSObject*)key
{
    
}

@end
