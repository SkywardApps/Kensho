#include "lua.h"
//#include "lauxlib.h"
#include <android/log.h>
#include <jni.h>

#define APPNAME "LUA"
#define INFO_TAG "[INFO]"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, INFO_TAG, __VA_ARGS__)

 JNIEXPORT jstring JNICALL Java_com_skywardapps_kenshotest_MainActivity_testLua(JNIEnv* env, jobject obj, jstring unused)
{
  jclass cls = (*env)->GetObjectClass(env, obj);
  jmethodID mid = (*env)->GetMethodID(env, cls, "callback", "()Ljava/lang/String;");
  if (mid == 0)
    return;

  jstring input = (*env)->CallObjectMethod(env, obj, mid);
  char* inputcstr = (*env)->GetStringUTFChars(env, input, NULL);

  //char* inputcstr = (*env)->GetStringUTFChars(env, unused, NULL);
  __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Got execution string %s", inputcstr);

 lua_State* L = luaL_newstate();
 luaL_openlibs(L);

 // load the test string
   luaL_loadstring(L, inputcstr);
    int resultCode = lua_pcall(L, 0, 1, 0);

   jstring j = NULL;
    if (0 == resultCode)
    {
         const char* res = lua_tostring(L, -1);
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Got result string %s", res);
         j = (*env)->NewStringUTF(env, res);
    }
    else
    {
        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME, "Error in LUA execution");
    }

  lua_pop(L, 1);
  lua_close(L);

 (*env)->ReleaseStringChars(env, input, inputcstr);
 //(*env)->ReleaseStringChars(env, unused, inputcstr);
 return j;
}
