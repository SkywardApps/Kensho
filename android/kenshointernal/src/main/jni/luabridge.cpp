extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#define APPNAME "LUA"

#include <android/log.h>
#include <jni.h>
#include <string>
#include <map>
#include <vector>
#include <sstream>
#include <iostream>

using namespace std;
using std::string;

class LuaWrapper {
    public:
        LuaWrapper(JNIEnv* env, jobject javaWrapper)
        {
            _env = env;
            _wrapperObject = javaWrapper;
            _wrapperClass = env->GetObjectClass(javaWrapper);
            _getTypeIdMethodId = env->GetStaticMethodID(_wrapperClass, "getTypeId", "(Ljava/lang/Class;)Ljava/lang/String;");
            _setParameterMethodId = env->GetMethodID(_wrapperClass, "setParameter", "(Ljava/lang/String;Ljava/lang/Object;)V");
            _numberFromDoubleMethodId = env->GetStaticMethodID(_wrapperClass, "numberFromDouble", "(D)Ljava/lang/Double;");
            _getPropertyMethodId = env->GetStaticMethodID(_wrapperClass, "getProperty", "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
            _doubleFromObjectMethodId = env->GetStaticMethodID(_wrapperClass, "doubleFromObject", "(Ljava/lang/Object;)D");
        }

        char getTypeId(jobject object)
        {
            // We get the class of the object, then invoke our java wrapper method (perhaps this can be written in C++?) to
            // get the type string back
            jstring typeIdJString = (jstring)_env->CallStaticObjectMethod(_wrapperClass, _getTypeIdMethodId, _env->GetObjectClass(object));
            const char* typeIdCString = _env->GetStringUTFChars(typeIdJString, NULL);
            char typeId = typeIdCString[0];
            _env->ReleaseStringUTFChars(typeIdJString, typeIdCString);
            return typeId;
        }

        void setResultParameter(const char* name, jobject value)
        {
            jstring nameJString = _env->NewStringUTF(name);
            _env->CallVoidMethod(_wrapperObject, _setParameterMethodId, nameJString, value);
        }

        jobject numberFromDouble(jdouble value)
        {
            return _env->CallStaticObjectMethod(_wrapperClass, _numberFromDoubleMethodId, value);
        }

        double doubleFromObject(jobject value)
        {
            return _env->CallStaticDoubleMethod(_wrapperClass, _doubleFromObjectMethodId, value);
        }

        jobject getProperty(jobject object, const char* name)
        {
           __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Getting Property: %s\n", name);
            jstring nameJString = _env->NewStringUTF(name);
            return _env->CallStaticObjectMethod(_wrapperClass, _getPropertyMethodId, object, nameJString);
        }

        JNIEnv* env() { return _env; }
    private:
        JNIEnv* _env;
        jobject _wrapperObject;
        jclass _wrapperClass;
        jmethodID _getTypeIdMethodId;
        jmethodID _setParameterMethodId;
        jmethodID _numberFromDoubleMethodId;
        jmethodID _doubleFromObjectMethodId;
        jmethodID _getPropertyMethodId;
};


static LuaWrapper* luaWrapper = NULL;


extern "C"
{
    int lookupKey(lua_State* L);
    jobject popValue(lua_State* L, int stackLevel, LuaWrapper* wrapper);

    int pushValue(lua_State* L, jobject value, LuaWrapper* wrapper)
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "pushValue\n");

        char type = wrapper->getTypeId(value);
        if(type == 'N')
        {
            double d = wrapper->doubleFromObject(value);
            lua_pushnumber(L, d);
            return 1;
        }
        else if(type == 'S')
        {
            jstring str = (jstring)value;
            const char* cstr = wrapper->env()->GetStringUTFChars(str, NULL);
            lua_pushstring(L, cstr);
            wrapper->env()->ReleaseStringUTFChars(str, cstr);
            return 1;
        }

        // Assign __self to refer to the value itself
        lua_createtable(L, 0, 1);
        lua_pushlightuserdata(L, value);
        lua_setfield(L, -2, "__self");
        lua_pushlightuserdata(L, wrapper);
        lua_setfield(L, -2, "__wrapper");

        // make sure that when LUA tries to dereference a property, it uses the lookupKey method to implement it.
        lua_createtable(L, 0, 1);
        lua_pushstring(L, "__index");
        lua_pushcfunction(L, lookupKey);
        lua_settable(L, -3);
        /*lua_pushstring(L, "__add");
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
        lua_settable(L, -3);*/

        //-- set global index callback hook
        lua_setmetatable(L, -2);

        if(!lua_istable(L, -1))
        {
            //NSLog(@"Stack is wrong");
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Stack is wrong\n");
        }
        return 1;
    }

    jobject popValue(lua_State* L, int stackLevel, LuaWrapper* wrapper)
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "popValue\n");
        // Now figure out the datatype of the assignment and get the data out
        if(lua_isboolean(L, stackLevel))
        {
            bool value = lua_toboolean(L, stackLevel);
            //return wrapper->boolToBoolean(value);
        }
        else if(lua_isnumber(L, stackLevel))
        {
            double value = lua_tonumber(L, stackLevel);
            return wrapper->numberFromDouble(value);
        }
        else if(lua_isstring(L, stackLevel))
        {
            const char* tempString = lua_tostring(L, stackLevel);
            return wrapper->env()->NewStringUTF(tempString);
        }
        else if(lua_istable(L, stackLevel))
        {
            // This is a bit of a special case here.  We assume this is a wrapper for an NSObject.
            // This could actually be a new table, in which case this will fail.
            lua_getfield(L, stackLevel, "__self");
            jobject value = (jobject)lua_touserdata(L, -1);

            // If this wasn't one of our wrapped objects, pop the table into a NSDictionary map.
            if(value == NULL)
            {
            /*
                // We'll create an NSDictionary wrapper here
                NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

                // stackLevel-1 is now the table we attempted to get
                while (lua_next(L, stackLevel-1) != 0) {
                    // uses 'key' (at index -2) and 'value' (at index -1)
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

                    // removes 'value'; keeps 'key' for next iteration
                    lua_pop(L, 1);
                    printf("%s\n", lua_typename(L, lua_type(L, -1)));
                    if(lua_isstring(L, -1))
                    {
                        const char* tempString = lua_tostring(L, -1);
                        printf("%s\n", tempString);
                    }
                }

                value = [NSDictionary dictionaryWithDictionary:dictionary];*/
            }
            else
            {
                lua_pop(L, 1);
            }
            return value;
        }

        return NULL;
    }

    int lookupKey(lua_State* L)
    {
        // Stack is [table, key]
        if(!lua_isstring(L, -1))
        {
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupKey not string\n");
            return 0;
        }

        if(!lua_istable(L, -2))
        {
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupKey not table\n");
            return 0;
        }



        // Get the pointer to the context object
        lua_getfield(L, -2, "__self");
        jobject target = (jobject)lua_touserdata(L, -1);
        if(target == NULL)
        {
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupKey NULL self\n");
            return 0;
        }
        lua_pop(L,1);

        lua_getfield(L, -2, "__wrapper");
        LuaWrapper* wrapper = (LuaWrapper*)lua_touserdata(L, -1);
        if(wrapper == NULL)
        {
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupKey NULL wrapper\n");
            return 0;
        }

        const char* nameRequest = lua_tostring(L, -2);
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupKey %s\n", nameRequest);
        if(nameRequest == NULL)
        {
            return 0;
        }

        // Now we need to potentially do a reflection map of this object
        // Now check if there is actually a property as requested
        // If so, call it and get the result
        jobject value = wrapper->getProperty(target, nameRequest);
        return pushValue(L, value, wrapper);
    }

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
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "lookupNewKey %s\n", nameRequest);
         if(nameRequest == NULL)
         {
             return 0;
         }

         // Get the pointer to the context table (the global table here)
         // And then get its __wrapper object, which points to the owning KenshoLuaWrapper.
         lua_getfield(L, -3, "__wrapper");
         LuaWrapper* target = (LuaWrapper*)lua_touserdata(L, -1);
         lua_pop(L, 1);
         if(target == NULL)
         {
             return 0;
         }

         jobject value = popValue(L, -1, target);

         // Ok, we save this value to the 'parameters' object
         target->setResultParameter(nameRequest, value);

         return 1;

    }

    JNIEXPORT jobject JNICALL Java_com_skywardapps_kensho_LuaWrapper_luaEvaluate(JNIEnv* env, jobject sender, jobject context, jstring code)
    {
        luaWrapper = new LuaWrapper(env, sender); // \todo worry about the lifetime of this

        const char* cstrLuaCode = env->GetStringUTFChars(code, NULL);

        lua_State* L = (lua_State *) luaL_newstate();
        luaL_openlibs(L);

        lua_pushlightuserdata(L, context);
        lua_setglobal(L, "__self");

        lua_pushlightuserdata(L, luaWrapper);
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

        /* run the test script */
        luaL_loadstring(L, cstrLuaCode);
        int resultCode = lua_pcall(L, 0, 1, 0);

        /*
         LUA_ERRRUN: a runtime error.
         LUA_ERRMEM: memory allocation error. For such errors, Lua does not call the error handler function.
         LUA_ERRERR: error while running the error handler function.
        */
        switch(resultCode)
        {
            case 0:
                // The success case here
                break;
            case LUA_ERRRUN:
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Runtime error: %s\n%s", lua_tostring(L, -1), cstrLuaCode);
                break;
            case LUA_ERRMEM:
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Memory allocation error: %s\n%s", lua_tostring(L, -1), cstrLuaCode);
                break;
            case LUA_ERRSYNTAX:
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Syntax error: %s\n%s", lua_tostring(L, -1), cstrLuaCode);
                break;
            case LUA_ERRERR:
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Error handler error: %s\n%s", lua_tostring(L, -1), cstrLuaCode);
                break;
        }

        env->ReleaseStringUTFChars(code, cstrLuaCode);

        return NULL;
    }
}