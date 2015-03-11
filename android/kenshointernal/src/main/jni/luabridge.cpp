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
            _booleanFromObjectMethodId = env->GetStaticMethodID(_wrapperClass, "booleanFromObject", "(Ljava/lang/Object;)Z");
            _unwrapMethodId = env->GetStaticMethodID(_wrapperClass, "unwrap", "(Ljava/lang/Object;)Ljava/lang/Object;");
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

        bool booleanFromObject(jobject value)
        {
            return _env->CallStaticBooleanMethod(_wrapperClass, _booleanFromObjectMethodId, value);
        }

        jobject getProperty(jobject object, const char* name)
        {
           __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Getting Property: %s\n", name);
            jstring nameJString = _env->NewStringUTF(name);
            return _env->CallStaticObjectMethod(_wrapperClass, _getPropertyMethodId, object, nameJString);
        }

        jobject unwrap(jobject object){
            return _env->CallStaticObjectMethod(_wrapperClass, _unwrapMethodId, object);
        }

        // converts a bool to
        jobject boolToBoolean(bool value){
            jclass booleanClass = _env->FindClass("java/lang/Boolean");

            // JNI reflection for instantiating a HashMap
            jmethodID init = _env->GetMethodID(booleanClass, "<init>", "(Z)V");
            return _env->NewObject(booleanClass, init, value);
        }

        // returns true if obj implements the comparable interface
        bool isComparable(jobject obj){

            jclass objectClass = _env->GetObjectClass(obj);

            jmethodID compareToId = _env->GetMethodID(objectClass, "compareTo", "(Ljava/lang/Object;)I");

            return compareToId != 0;
        }

        // uses the compareTo method to compare left and right
        jint compare(jobject left, jobject right){
            jclass leftObjectClass = _env->GetObjectClass(left);

            jmethodID compareToId = _env->GetMethodID(leftObjectClass, "compareTo", "(Ljava/lang/Object;)I");

            return _env->CallIntMethod(left, compareToId, right);
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
        jmethodID _booleanFromObjectMethodId;
        jmethodID _getPropertyMethodId;
        jmethodID _unwrapMethodId;
};


static LuaWrapper* luaWrapper = NULL;


extern "C"
{
    int lookupKey(lua_State* L);
    int concatValues(lua_State* L);
    int addValues(lua_State* L);
    int subtractValues(lua_State* L);
    int multiplyValues(lua_State* L);
    int divideValues(lua_State* L);
    int exponentValues(lua_State* L);
    int modulusValues(lua_State* L);
    int lessValues(lua_State* L);
    int equalsValues(lua_State* L);
    jobject getValue(lua_State* L, int stackLevel, LuaWrapper* wrapper);
    LuaWrapper* findWrapper(lua_State* L);
    void stackDump(lua_State* L);

    int pushValue(lua_State* L, jobject value, LuaWrapper* wrapper)
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "pushValue\n");

        char type = wrapper->getTypeId(value);
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Type: %c\n", type );
        if(type == 'N')
        {
            double d = wrapper->doubleFromObject(value);
            lua_pushnumber(L, d);
            return 1;
        }
        else if(type == 'B')
        {
            bool b = wrapper->booleanFromObject(value);

            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Pushing boolean value: %s", b?"true":"false" );
            lua_pushboolean(L, b);
            return 1;
        }
        else if(type == 'S')
        {
            jstring str = (jstring)value;
            const char* cstr = wrapper->env()->GetStringUTFChars(str, NULL);
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "String value: %s\n", cstr );
            lua_pushstring(L, cstr);
            wrapper->env()->ReleaseStringUTFChars(str, cstr);
            return 1;
        }
        else if (type == 'K' || type == 'O')
        {
             // Assign __self to refer to the value itself
             lua_createtable(L, 0, 2);
             lua_pushlightuserdata(L, value);
             lua_setfield(L, -2, "__self");
             lua_pushlightuserdata(L, wrapper);
             lua_setfield(L, -2, "__wrapper");

             // make sure that when LUA tries to dereference a property, it uses the lookupKey method to implement it.
             lua_createtable(L, 0, 2);
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
             /*lua_pushstring(L, "__call");
             lua_pushcfunction(L, callValue);
             lua_settable(L, -3);*/

             //-- set global index callback hook
             lua_setmetatable(L, -2);

             if(!lua_istable(L, -1))
             {
                 __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Stack is wrong\n");
             }
             return 1;
        }

        // this shouldn't happen(?), so return error
        return 0;
    }

    /**
     *  returns a pointer to the luawrapper class by inspecting the stack for it
     */
    LuaWrapper* findWrapper(lua_State* L){
        LuaWrapper* wrapper;
        if(lua_istable(L, -1)){
            lua_getfield(L, -1, "__wrapper");
            // wrapper is now the top of the stack
            wrapper = (LuaWrapper*)lua_touserdata(L, -1);
        } else {
            lua_getfield(L, -2, "__wrapper");
            // wrapper is now the top of the stack
            wrapper = (LuaWrapper*)lua_touserdata(L, -1);
        }
        // pop the wrapper
        lua_pop(L, 1);
        return wrapper;
    }

    int concatValues(lua_State* L)
    {
        char *rightStr, *leftStr;

        // attempt to find the wrapper object within either the first or second stack item
        LuaWrapper* wrapper = findWrapper(L);

        jstring rightString = (jstring)wrapper->unwrap(getValue(L, -1, wrapper));
        jstring leftString = (jstring)wrapper->unwrap(getValue(L, -2, wrapper));

        // pop both strings from the stack
        lua_pop(L, 1);
        lua_pop(L, 1);

        // convert the jstrings to c strings and concat
        rightStr = (char*)wrapper->env()->GetStringUTFChars(rightString, NULL);
        leftStr = (char*)wrapper->env()->GetStringUTFChars(leftString, NULL);
        lua_pushstring(L, strcat(leftStr,rightStr));
        return 1;
    }

    int addValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, leftNumber + rightNumber);
        return 1;
    }

    int subtractValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, leftNumber - rightNumber);
        return 1;
    }

    int multiplyValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, leftNumber * rightNumber);
        return 1;
    }

    int exponentValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, pow(leftNumber, rightNumber));
        return 1;
    }

    int divideValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, leftNumber / rightNumber);
        return 1;
    }

    int lessValues(lua_State* L)
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "calling compareTo method...\n");
        jobject rightObject, leftObject;
        LuaWrapper* wrapper = findWrapper(L);
        rightObject = wrapper->unwrap(getValue(L, -1, wrapper));
        leftObject = wrapper->unwrap(getValue(L, -2, wrapper));

        if(!wrapper->isComparable(leftObject)) return 0;
        if(!wrapper->isComparable(rightObject)) return 0;

        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "we've comparables!...\n");

        jint less = wrapper->compare(leftObject, rightObject);

        lua_pop(L, 1);
        lua_pop(L, 1);
        if(less)
            lua_pushboolean(L, true); // return true
        else
            lua_pushboolean(L, false); // return false
        return 1;
    }

    int equalsValues(lua_State* L)
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "calling equals method...\n");
        jobject rightObject, leftObject;
        LuaWrapper* wrapper = findWrapper(L);
        rightObject = wrapper->unwrap(getValue(L, -1, wrapper));
        leftObject = wrapper->unwrap(getValue(L, -2, wrapper));

        // call the java equals method
        jmethodID equalsMethodID = wrapper->env()->GetMethodID(wrapper->env()->GetObjectClass(leftObject), "equals", "(Ljava/lang/Object;)Z");
        jboolean isEqual = wrapper->env()->CallBooleanMethod(leftObject, equalsMethodID, rightObject);

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushboolean(L, (bool)isEqual);
        return 1;
    }

    int modulusValues(lua_State* L)
    {
        double rightNumber, leftNumber;
        LuaWrapper* wrapper = findWrapper(L);
        rightNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -1, wrapper)));
        leftNumber = wrapper->doubleFromObject(wrapper->unwrap(getValue(L, -2, wrapper)));

        lua_pop(L, 1);
        lua_pop(L, 1);
        lua_pushnumber(L, leftNumber - floor(leftNumber/rightNumber)*rightNumber);
        return 1;
    }

    jobject getValue(lua_State* L, int stackLevel, LuaWrapper* wrapper)
    {
        // Now figure out the datatype of the assignment and get the data out
        if(lua_isboolean(L, stackLevel))
        {
            bool value = lua_toboolean(L, stackLevel);
            return wrapper->boolToBoolean(value);
        }
        else if(lua_isnumber(L, stackLevel))
        {
            double value = lua_tonumber(L, stackLevel);
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "getValue: %f\n", value);
            return wrapper->numberFromDouble(value);
        }
        else if(lua_isstring(L, stackLevel))
        {
            const char* tempString = lua_tostring(L, stackLevel);
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "getValue: %s\n", tempString);
            return wrapper->env()->NewStringUTF(tempString);
        }
        else if(lua_istable(L, stackLevel))
        {
            // This must be an ObservableValue
            // get the value and
            lua_getfield(L, stackLevel, "__self");
            jobject value = (jobject)lua_touserdata(L, -1);

            // If this wasn't one of our wrapped objects, pop the table into a NSDictionary map.
            if(value == NULL)
            {
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Nested Object!\n");
                // We'll create an HashMap wrapper here
                jclass mapClass = wrapper->env()->FindClass("java/util/HashMap");
                if(mapClass == NULL)
                {
                    return NULL;
                }

                // JNI reflection for instantiating a HashMap
                jmethodID init = wrapper->env()->GetMethodID(mapClass, "<init>", "(V)V");
                jobject hashMap = wrapper->env()->NewObject(mapClass, init);

                // get a pointer to the put function
                jmethodID put = wrapper->env()->GetMethodID(mapClass, "put",
                            "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");

                // stackLevel-1 is now the table we attempted to get
                while (lua_next(L, stackLevel-1) != 0) {
                    // uses 'key' (at index -2) and 'value' (at index -1)
                    __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%s\n", lua_typename(L, lua_type(L, -2)));
                    if(lua_isstring(L, -2))
                    {
                        const char* tempString = lua_tostring(L, -2);
                        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%s\n", tempString);

                    }
                    // Make sure the key is a valid string too!
                    const char* nameRequest = lua_tostring(L, -2);
                    if(nameRequest == NULL)
                    {
                        return 0;
                    }

                    jobject subvalue = getValue(L, -1, wrapper);
                    jstring nr = wrapper->env()->NewStringUTF(nameRequest);
                    wrapper->env()->CallObjectMethod(hashMap, put, nr, subvalue);

                    // removes 'value'; keeps 'key' for next iteration
                    lua_pop(L, 1);
                    __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%s\n", lua_typename(L, lua_type(L, -1)));
                    if(lua_isstring(L, -1))
                    {
                        const char* tempString = lua_tostring(L, -1);
                        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%s\n", tempString);
                    }
                }

                value = hashMap;
            }
            else
            {
                __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Value was not null\n");
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

         jobject value = getValue(L, -1, target);

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

        //delete luaWrapper;
        //luaWrapper = NULL;

        env->ReleaseStringUTFChars(code, cstrLuaCode);

        return NULL;
    }

    /**
     *  prints the current lua stack
     */
    void stackDump (lua_State *L) {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%s\n", "Stack Dump");
      int i;
      int top = lua_gettop(L);
      for (i = 1; i <= top; i++) {  /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {

          case LUA_TSTRING:  /* strings */
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%d: %s\n", i, lua_tostring(L, i));
            break;

          case LUA_TBOOLEAN:  /* booleans */
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%d: %s\n", i, lua_toboolean(L, i) ? "true" : "false");
            break;

          case LUA_TNUMBER:  /* numbers */
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%d: %g\n", i, lua_tonumber(L, i));
            break;

          default:  /* other values */
            __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "%d: %s\n", i, lua_typename(L, t));
            break;

        }
      }
      __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "\n");  /* end the listing */
    }
}
