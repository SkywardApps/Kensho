extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
}

#define APPNAME "LUA"

#include <android/log.h>
#include <jni.h>
#include <string>
using std::string;
#include <map>
using std::map;
#include <vector>
using std::vector;

class LuaWrapper {
    public:
        LuaWrapper(JNIEnv* env, jobject javaWrapper)
        {
            _env = env;
            _wrapperClass = env->GetObjectClass(javaWrapper);
            _getTypeIdMethodId = env->GetMethodID(_wrapperClass, "getTypeId", "(Ljava/lang/Class;)Ljava/lang/String;");
            _setParameterMethodId = env->GetMethodID(_wrapperClass, "setParameter", "(Ljava/lang/String;Ljava/lang/Object;)V");
            _reflectMethodId = env->GetMethodID(_wrapperClass, "reflect", "(Ljava/lang/Class;)[Ljava/lang/String;");
        }

        char getTypeId(jobject object)
        {
            // We get the class of the object, then invoke our java wrapper method (perhaps this can be written in C++?) to
            // get the type string back
            jstring typeIdJString = (jstring)_env->CallObjectMethod(_wrapperClass, _getTypeIdMethodId, _env->GetObjectClass(object));
            const char* typeIdCString = _env->GetStringUTFChars(typeIdJString, NULL);
            char typeId = typeIdCString[0];
            _env->ReleaseStringUTFChars(typeIdJString, typeIdCString);
            return typeId;
        }

        void setResultParameter(string name, jobject value)
        {
            jstring nameJString = _env->NewStringUTF(name.c_str());
            _env->CallObjectMethod(_wrapperClass, _setParameterMethodId, nameJString, value);
        }
    private:
        JNIEnv* _env;
        jclass _wrapperClass;
        jmethodID _getTypeIdMethodId;
        jmethodID _setParameterMethodId;
        jmethodID _reflectMethodId;
};
static LuaWrapper* luaWrapper = NULL;

class javaproperty {
public:
    bool isMethod;
    bool canSet;
    int methodId;
    char returnType;
};

int pushValue(lua_State* L, jobject value)
{
    return 1;
}

int lookupKey(lua_State* L)
{
    // Stack is [table, key]
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
    jobject target = (jobject)lua_touserdata(L, -1);
    if(target == NULL)
    {
        return 0;
    }

    const char* nameRequest = lua_tostring(L, -2);
    if(nameRequest == NULL)
    {
        return 0;
    }

    // Now we need to potentially do a reflection map of this object
    // Now check if there is actually a property as requested
    // If so, call it and get the result
    jobject value = NULL;
    return pushValue(L, value);
}

int lookupNewKey(lua_State* L)
{
    return 0;
}


JNIEXPORT jobject JNICALL Java_com_skywardapps_kensho_LuaWrapper_luaEvaluate(JNIEnv* env, jobject sender, jobject context, jstring code)
{
    if(luaWrapper == NULL)
    {
        luaWrapper = new LuaWrapper(env, sender);
    }

    const char* cstrLuaCode = env->GetStringUTFChars(code, NULL);

    lua_State* L = (lua_State *) luaL_newstate();
    luaL_openlibs(L);

    lua_pushlightuserdata(L, context);
    lua_setglobal(L, "__self");

    lua_pushlightuserdata(L, sender);
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
    if (0 != resultCode)
    {
        /*
         LUA_ERRRUN: a runtime error.
         LUA_ERRMEM: memory allocation error. For such errors, Lua does not call the error handler function.
         LUA_ERRERR: error while running the error handler function.
        */
        switch(resultCode)
        {
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
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Error handler error: %s\n%S", lua_tostring(L, -1), cstrLuaCode);
                break;
        }
    }

    env->ReleaseStringUTFChars(code, cstrLuaCode);

    return NULL;
}

