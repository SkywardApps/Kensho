package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.Computed;
import com.skywardapps.kensho.LuaWrapper;
import com.skywardapps.kensho.ObservableValue;
import com.skywardapps.kensho.WatchableBase;

import java.util.ArrayList;

/**
 * Created by nelliott on 2/23/15.
 */
public class TestLuaWrapper extends InstrumentationTestCase {
    public void testReflect()
    {
        LuaWrapper.reflect(WatchableBase.class);
    }

    public int fakeMethod(Object unused) { return 0; }

    public void testTypeId() throws NoSuchMethodException
    {
        assertEquals("N", LuaWrapper.getTypeId(Number.class));
        assertEquals("N", LuaWrapper.getTypeId(Integer.class));
        assertEquals("i", LuaWrapper.getTypeId(int.class));
        assertEquals("N", LuaWrapper.getTypeId(Double.class));
        assertEquals("d", LuaWrapper.getTypeId(double.class));
        assertEquals("y", LuaWrapper.getTypeId(byte.class));
        assertEquals("B", LuaWrapper.getTypeId(Boolean.class));
        assertEquals("b", LuaWrapper.getTypeId(boolean.class));
        assertEquals("S", LuaWrapper.getTypeId(String.class));
        assertEquals("O", LuaWrapper.getTypeId(Object.class));
        assertEquals("O", LuaWrapper.getTypeId(ArrayList.class));

        assertEquals("K", LuaWrapper.getTypeId(ObservableValue.class));
        assertEquals("K", LuaWrapper.getTypeId(Computed.class));

        Class returnType = this.getClass().getMethod("fakeMethod", Object.class).getReturnType();
        assertEquals("i", LuaWrapper.getTypeId(returnType));
    }
}
