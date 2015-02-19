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
#import "IObservable.h"
#import "NSObject+Observable.h"
#import "ObservablePropertyReference.h"

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



/**
 
 For each arithmetic operator there is a corresponding field name in a metatable. Besides __add and __mul, there are __sub (for subtraction), __div (for division), __unm (for negation), and __pow (for exponentiation). We may define also the field __concat, to define a behavior for the concatenation operator.
 
 So maybe we need a KVO object wrapping the context and the property name, and we use that instead of the actual value.  That way when we return the parameters array, we can actually return the bound property, not just the value
 
 */

@interface KenshoLuaWrapper ()
{
    // The kensho context object
    KenshoContext* context;
    Kensho* ken;
}

@property (readwrite) NSMutableDictionary* parameters;
@property (atomic, strong) NSString* code;

@end

NSMutableArray* valueWrappers;

int lookupKey(lua_State* L);
int pushValue(lua_State* L, NSObject* value);
int addValues(lua_State* L);
int subtractValues(lua_State* L);
int multiplyValues(lua_State* L);
int divideValues(lua_State* L);
int exponentValues(lua_State* L);
int modulusValues(lua_State* L);
int concatValues(lua_State* L);
int equalsValues(lua_State* L);
int lessValues(lua_State* L);
int callValue(lua_State* L);

/**
 *  Push an NSObject-derived value onto the stack
 *
 *  @param L     <#L description#>
 *  @param value <#value description#>
 *
 *  @return 0 on error, otherwise 1.
 */
int pushValue(lua_State* L, ObservablePropertyReference* valueWrapper)
{
    // So now, we're always pushing an object! It wraps the source, name, and value
    // Allocate the new userdata lua-object \todo this looks redundant now?
    NSObject* __weak *userdata = (NSObject* __weak *)lua_newuserdata(L, sizeof(NSObject*));
    (*userdata) = valueWrapper;
    
    // Assign __self to refer to the value itself
    lua_createtable(L, 0, 1);
    lua_pushlightuserdata(L, (__bridge void *)(valueWrapper));
    lua_setfield(L, -2, "__self");

    // make sure that when LUA tries to dereference a property, it uses the lookupKey method to implement it.
    lua_createtable(L, 0, 1);
    lua_pushstring(L, "__index");
    lua_pushcfunction(L, lookupKey);
    lua_settable(L, -3);
    lua_pushstring(L, "__add");
    lua_pushcfunction(L, addValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__sub");
    lua_pushcfunction(L, subtractValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__mul");
    lua_pushcfunction(L, multiplyValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__div");
    lua_pushcfunction(L, divideValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__pow");
    lua_pushcfunction(L, exponentValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__mod");
    lua_pushcfunction(L, modulusValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__concat");
    lua_pushcfunction(L, concatValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__eq");
    lua_pushcfunction(L, equalsValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__lt");
    lua_pushcfunction(L, lessValues);
    lua_settable(L, -3);
    lua_pushstring(L, "__call");
    lua_pushcfunction(L, callValue);
    lua_settable(L, -3);
    
    //-- set global index callback hook
    lua_setmetatable(L, -2);
    
    if(!lua_istable(L, -1))
    {
        NSLog(@"Stack is wrong");
    }
    return 1;
}

int pushLuaValue(lua_State* L, NSObject* value)
{
    // Handle a generic number
    if([value isKindOfClass:NSNumber.class])
    {
        lua_pushnumber(L, [(NSNumber*)value doubleValue]);
        return 1;
    }
    // Handle a string
    else if([value isKindOfClass:NSString.class])
    {
        lua_pushstring(L, [(NSString*)value UTF8String]);
        return 1;
    }
    // Handle a complex object of generic kind
    else if([value isKindOfClass:NSObject.class])
    {
        // Allocate the new userdata lua-object
        NSObject* __weak *userdata = (NSObject* __weak *)lua_newuserdata(L, sizeof(NSObject*));
        (*userdata) = value;
        
        // Assign __self to refer to the value itself
        lua_createtable(L, 0, 1);
        lua_pushlightuserdata(L, (__bridge void *)(value));
        lua_setfield(L, -2, "__self");
        
        // make sure that when LUA tries to dereference a property, it uses the lookupKey method to implement it.
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

/**
 *  This is executed when the LUA subsystem attempts to read data to from an index that it doesn't think exists.
 *
 *  @param L The LUA state object
 *
 *  @return 0 on error, otherwise 1.
 */
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
    
    target = [ObservablePropertyReference unwrap:target];
    
    /**
     * @todo Consider how to pass-through property references.
     * This is important for two cases:
     * - Tight binding to collections (eg, add an item, remove an item. re-order)
     * - Two-way binding, to allow assignment
     *
     * Knockout lets you specify a property name, eg value: 'myValue' (at least for items in a list)
     * It would be nice if we could do this automagically, eg: value = my.value;
     */
    NSString* propertyName = [NSString stringWithUTF8String:nameRequest];
    /*NSObject* value = [target valueForKey:propertyName];
    if(value == nil)
    {
        return 0;
    }*/
    
    // Push the value requested onto the stack, wrapped as appropriate
    ObservablePropertyReference* valueWrapper = [[ObservablePropertyReference alloc] initWithOwner:target
                                                                                      propertyName:propertyName];
    [valueWrappers addObject:valueWrapper];
    return pushValue(L, valueWrapper);
}

NSObject* popValue(lua_State* L, int stackLevel)
{
    // Now figure out the datatype of the assignment and get the data out
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
        
        // If this wasn't one of our wrapped objects, pop the table into a NSDictionary map.
        if(value == nil)
        {
            
            // We'll create an NSDictionary wrapper here
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
            
            // stackLevel-1 is now the table we attempted to get
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
        else
        {
            lua_pop(L, 1);
        }
        /*printf("%s\n", lua_typename(L, lua_type(L, -1)));
        if(lua_isstring(L, -1))
        {
            const char* tempString = lua_tostring(L, -1);
            printf("%s\n", tempString);
            
        }*/
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
    // And then get its __wrapper object, which points to the owning KenshoLuaWrapper.
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

int addValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, left.doubleValue + right.doubleValue);
    return 1;
}

int subtractValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, left.doubleValue - right.doubleValue);
    return 1;
}

int multiplyValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, left.doubleValue * right.doubleValue);
    return 1;
}

int divideValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, left.doubleValue / right.doubleValue);
    return 1;
}

int exponentValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, pow(left.doubleValue, right.doubleValue));
    return 1;
}

int modulusValues(lua_State* L)
{
    NSNumber* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSNumber* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushnumber(L, left.doubleValue - floor(left.doubleValue/right.doubleValue)*right.doubleValue);
    return 1;
}

int concatValues(lua_State* L)
{
    NSString* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSString* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushstring(L, [left stringByAppendingString:right].UTF8String);
    return 1;
}

int equalsValues(lua_State* L)
{
    NSObject* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSObject* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    lua_pushboolean(L, [left isEqual:right]);
    return 1;
}

int lessValues(lua_State* L)
{
    NSObject* left = [ObservablePropertyReference unwrap:popValue(L, -2)];
    NSObject* right = [ObservablePropertyReference unwrap:popValue(L, -1)];
    if([left respondsToSelector:@selector(compare:)])
    {
        lua_pushboolean(L, [(id)left compare:right] == NSOrderedAscending);
        return 1;
    }
    return 0;
}

int callValue(lua_State* L)
{
    NSObject* parameter = popValue(L, -lua_gettop(L));
    if(![parameter isKindOfClass:ObservablePropertyReference.class])
    {
        return 0;
    }
    ObservablePropertyReference* reference = (ObservablePropertyReference*)parameter;
    
    id object = reference.owner;
    if([object isKindOfClass:KenshoContext.class])
    {
        object = [object context];
    }
    
    NSString* selectorName = reference.propertyName;
    SEL selector = NSSelectorFromString(selectorName);
    if([object respondsToSelector:selector])
    {
        /**
         *   \todo support native-type returns, not just NSObject*s.
         *  This is a very complicated situation - see 'makeClassObservable' in NSObject+Observable.m
         */
        NSObject* result = [object performSelector:selector];
        pushLuaValue(L, result);
        return 1;
    }
    
    selectorName = [selectorName stringByAppendingString:@":"];
    selector = NSSelectorFromString(selectorName);
    if([object respondsToSelector:selector])
    {
        NSObject* argument = popValue(L, -1);
        NSObject* result = [object performSelector:selector withObject:argument];
        pushLuaValue(L, result);
        return 1;
    }
    
    return 0;
}

@implementation KenshoLuaWrapper

- (id) initWithKensho:(Kensho *)initken context:(id)initcontext code:(NSString *)initcode
{
    if((self = [super initWithKensho:initken calculator:^NSObject *(NSObject * wrapper) {
        return [(KenshoLuaWrapper*)wrapper finalValue];
    }]))
    {
        ken = initken;
        context = initcontext;
        valueWrappers = [NSMutableArray array];
        _parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.code = initcode;
    }
    return self;
}

- (NSObject*) evaluate:(NSString*)newCode
{
    self.code = newCode;
    return self.currentValue;
}

- (NSDictionary *)parameters
{
    // Update the values
    return _parameters;
}

- (NSObject*) finalValue
{
    if(self.code == nil || [self.code isEqualToString:@""])
    {
        return nil;
    }
    
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
    
    NSString* embeddedString = [NSString stringWithFormat:@"__final = %@;", self.code];
    
    /* run the test script */
    luaL_loadstring(L, embeddedString.UTF8String);
    int resultCode = lua_pcall(L, 0, 1, 0);
    if (0 == resultCode)
    {
        NSObject* result =  _parameters[@"__final"];
        return [ObservablePropertyReference unwrap:result];
    }
    /* 
     LUA_ERRRUN: a runtime error.
     LUA_ERRMEM: memory allocation error. For such errors, Lua does not call the error handler function.
     LUA_ERRERR: error while running the error handler function.
    */
    else switch(resultCode)
    {
        case LUA_ERRRUN:
            NSLog(@"Runtime error: %s\n%@", lua_tostring(L, -1), _code);
            break;
        case LUA_ERRMEM:
            NSLog(@"Memory allocation error: %s\n%@", lua_tostring(L, -1), _code);
            break;
        case LUA_ERRSYNTAX:
            NSLog(@"Syntax error: %s\n%@", lua_tostring(L, -1), _code);
            break;
        case LUA_ERRERR:
            NSLog(@"Error handler error: %s\n%@", lua_tostring(L, -1), _code);
            break;
    }

    return nil;
}

@end
