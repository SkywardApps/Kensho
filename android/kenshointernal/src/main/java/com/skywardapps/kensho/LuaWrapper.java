package com.skywardapps.kensho;

import android.util.Log;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * A complex object that computes an observable value based on a LUA script
 *
 * This object serves double duty as both the LUA interpreter, as well as the Java -- NDK
 * bridge.
 *
 * Created by nelliott on 2/23/15.
 */
public class LuaWrapper extends Computed
{
    Object _context;
    String _code;
    HashMap<String, Object> _parameters;

    public LuaWrapper(Kensho kensho, Object context, String code)
    {
        super(kensho);
        _code = code;
        _context = context;
        trackCompute();
    }

    public static boolean booleanFromObject(Object b)
    {
        if(Boolean.class.isAssignableFrom(b.getClass()))
        {
            Boolean bool = (Boolean)b;
            return bool.booleanValue();
        }

        if(b.getClass() == boolean.class)
        {
            return (boolean)b;
        }

        return false;
    }

    public static Double numberFromDouble(double d)
    {
        return new Double(d);
    }

    public static double doubleFromObject(Object d)
    {
        if(Number.class.isAssignableFrom(d.getClass()))
        {
            Number n = (Number) d;
            return n.doubleValue();
        }

        if(d.getClass() == int.class)
        {
            return (int)d;
        }

        if(d.getClass() == double.class)
        {
            return (double)d;
        }

        if(d.getClass() == float.class)
        {
            return (float)d;
        }

        if(d.getClass() == long.class)
        {
            return (long)d;
        }

        if(d.getClass() == short.class)
        {
            return (short)d;
        }

        if(d.getClass() == byte.class)
        {
            return (byte)d;
        }

        if(d.getClass() == char.class)
        {
            return (char)d;
        }
        return 0;
    }

    static {
        System.loadLibrary("lua");
    }

    @Override
    protected Object compute() {
        _parameters = new HashMap<String, Object>();

        if(_code == null || _context == null || _code.isEmpty())
            return null;

        // Ok, pass off to the lua library now
        Object result = luaEvaluate(_context, "__final = "+_code+";");
        if(result == null) {
            // Success case
            return _parameters.get("__final");
        }
        // Otherwise the result is an error of some kind

        return null;
    }

    public static String getTypeId(Class typeClass) {
        String sig = typeClass.toString();
        String canon = typeClass.getCanonicalName();
        String simple = typeClass.getSimpleName();
        String name = typeClass.getName();

        String returnTypeId = "";
        if(typeClass.isPrimitive())
        {
            /*
               builtInMap("int", Integer.TYPE );
               builtInMap("long", Long.TYPE );
               builtInMap("double", Double.TYPE );
               builtInMap("float", Float.TYPE );
               builtInMap("bool", Boolean.TYPE );
               builtInMap("char", Character.TYPE );
               builtInMap("byte", Byte.TYPE );
               builtInMap("void", Void.TYPE );
               builtInMap("short", Short.TYPE );
             */
            if(typeClass.equals(boolean.class))
            {
                returnTypeId = "B";
            }
            else
            {
                returnTypeId = "N";
            }
        }
        else if(IObservable.class.isAssignableFrom(typeClass))
        {
            returnTypeId = "K";
        }
        else if(String.class.isAssignableFrom(typeClass))
        {
            returnTypeId = "S";
        }
        else if(Number.class.isAssignableFrom(typeClass))
        {
            returnTypeId = "N";
        }
        else if(Boolean.class.isAssignableFrom(typeClass))
        {
            returnTypeId = "B";
        }
        else
        {
            returnTypeId = "O";
        }

        return returnTypeId;
    }

    /**
     * Use runtime reflection to get the value of a property set on an object.
     *
     * This will first look for any public fields named as the property is, case-insensitive.
     * If there are no appropriate fields, then it will look for a method with no parameters,
     * returning a value, that has the same name as the property (case-insensitve) or the property
     * name prefixed with a 'get'.
     *
     * @param instance The object to reference.
     * @param propertyName The name of the property to access.
     * @return The value of the property referenced.
     */
    public static Object getProperty(Object instance, String propertyName)
    {
        Class objectClass = instance.getClass();

        try {
            Field field = objectClass.getField(propertyName);
            if(field != null)
            {
                return field.get(instance);
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

        for(Method method : objectClass.getMethods())
        {
            // Ignore anything that takes a parameter
            if(method.getParameterTypes().length > 0)
                continue;

            // Ignore anything that doesn't start with 'get'
            if(method.getReturnType() == void.class)
                continue;

            if(method.getName().toLowerCase().equals(propertyName)
                    || method.getName().toLowerCase().equals(("get" + propertyName).toLowerCase()))
            {
                try {
                    return method.invoke(instance, (Object[]) null);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    /**
     * Maps to a native method that will evaluate the LUA script in the context of a data model.
     *
     * @param context The data model to be run in the context of
     * @param code The LUA script to evaluate
     * @return The resulting object calculated from the LUA script.
     */
    private native Object luaEvaluate(Object context, String code);

    /**
     * Return the map of parameters set in the LUA script.
     * @return
     */
    public HashMap<String, Object> parameters(){
        return _parameters;
    }

    /**
     * Set a parameter.  Invoked by the NDK side of the bridge
     * @param key
     * @param value
     */
    public void setParameter(String key, Object value)
    {
        _parameters.put(key, value);
    }
}
