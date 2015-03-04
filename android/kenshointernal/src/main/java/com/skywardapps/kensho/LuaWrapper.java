package com.skywardapps.kensho;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;

/**
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

    public Double numberFromDouble(double d)
    {
        return new Double(d);
    };

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

    public static String[] reflect(Class targetClass)
    {
        ArrayList<String> properties = new ArrayList<>();

        /// public fields too
        for(Field field : targetClass.getFields())
        {
            Class fieldClass = field.getType();
            String fieldClassId = getTypeId(fieldClass);

            properties.add( "F" + "."
                    + field.getName().toLowerCase() + "."
                    + field.getName() + "."
                    + field.getType());
        }

        for(Method method : targetClass.getMethods())
        {
            // Ignore anything that takes a parameter
            if(method.getParameterTypes().length > 0)
                continue;

            // Ignore anything that doesn't start with 'get'
            if(!method.getName().startsWith("get"))
                continue;

            String fragment = method.getName().substring(3);
            Class returnClass = method.getReturnType();
            String returnTypeId = getTypeId(returnClass);

            String setterName = "";
            try {
                Method setter = targetClass.getMethod("set" + fragment, returnClass);
                setterName = setter.getName();
            }
            catch(NoSuchMethodException ex)
            {

            }

            properties.add( "M"+"."
                            + fragment.toLowerCase() + "."
                            + method.getName() +"."
                            + setterName + "."
                            + returnTypeId);
        }
        return properties.toArray(new String[0]);
    }

    public static String getTypeId(Class typeClass) {
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
            returnTypeId = typeClass.getName().substring(0,1);
            if(typeClass.equals(byte.class))
            {
                returnTypeId = "y";
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

    private native Object luaEvaluate(Object context, String code);

    public HashMap<String, Object> parameters(){
        return _parameters;
    }

    private void setParameter(String key, Object value)
    {
        _parameters.put(key, value);
    }
}
