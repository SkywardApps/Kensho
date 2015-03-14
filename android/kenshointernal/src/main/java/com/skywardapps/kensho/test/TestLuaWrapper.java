package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.Computed;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.LuaWrapper;
import com.skywardapps.kensho.ObservableValue;
import com.skywardapps.kensho.WatchableBase;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by nelliott on 2/23/15.
 */
public class TestLuaWrapper extends InstrumentationTestCase {

    public int fakeMethod(Object unused) { return 0; }

    public void testTypeId() throws NoSuchMethodException
    {
        assertEquals("N", LuaWrapper.getTypeId(Number.class));
        assertEquals("N", LuaWrapper.getTypeId(Integer.class));
        assertEquals("N", LuaWrapper.getTypeId(int.class));
        assertEquals("N", LuaWrapper.getTypeId(Double.class));
        assertEquals("N", LuaWrapper.getTypeId(double.class));
        assertEquals("N", LuaWrapper.getTypeId(byte.class));
        assertEquals("B", LuaWrapper.getTypeId(Boolean.class));
        assertEquals("B", LuaWrapper.getTypeId(boolean.class));
        assertEquals("S", LuaWrapper.getTypeId(String.class));
        assertEquals("O", LuaWrapper.getTypeId(Object.class));
        assertEquals("O", LuaWrapper.getTypeId(ArrayList.class));

        assertEquals("K", LuaWrapper.getTypeId(ObservableValue.class));
        assertEquals("K", LuaWrapper.getTypeId(Computed.class));

        Class returnType = this.getClass().getMethod("fakeMethod", Object.class).getReturnType();
        assertEquals("N", LuaWrapper.getTypeId(returnType));
    }

    public void testPassThrough(){
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, this, "5");
        assertEquals(wrapper.get(), new Double(5));
    }

    public void testBasicEvaluation()
    {
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, this, "2+3");
        assertEquals(wrapper.get(), new Double(5));
    }

    public class TestObject {
        public String myField = "My Field is set";
        public String getMethod() { return "My Method returns" ;}
        public double getNumber() { return 5.5; }

        public double getDouble() { return 0.1; }
        public float getFloat() { return 0.2f; }
        public Double getDoubleObject() { return new Double(0.4); }
        public Float getFloatObject() { return new Float(0.8f); }

        public byte getByteNum() { return 1; }
        public short getShortNum() { return 4; }
        public int getIntNum() { return 8; }
        public long getLongNum() { return 16; }

        public boolean getBooleanTrue() { return true; }
        public boolean getBooleanFalse() { return false; }

        public String getStringHW() { return "Hello World"; }

        public TestObject getNestedObject() { return new TestObject(); }

        public ObservableValue observableValue;
    }

    public void testFieldReference()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "myField");
        assertEquals(wrapper.get(), "My Field is set");
    }

    public void testMethodReference()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "method");
        assertEquals("My Method returns", wrapper.get());
    }

    public void testLuaFunction()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "number + 1.1");
        assertEquals(6.6, wrapper.get());
    }

    public void testBooleans()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "not booleanTrue");
        assertEquals(false, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "booleanTrue");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "booleanFalse");
        assertEquals(false, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "not booleanFalse");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "booleanTrue and not booleanFalse");
        assertEquals(true, wrapper.get());
    }

    public void testFloatingPointNumbers()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "float + double + floatObject + doubleObject");
        assertEquals(0.1 + 0.2f + 0.4 + 0.8f, wrapper.get());
    }

    public void testIntegerNumbers()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "bytenum + shortnum + intnum + longnum");
        assertEquals((double)(1+4+8+16), wrapper.get());
    }

    public void testStrings()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "stringHW .. \"!\"");
        assertEquals("Hello World!", wrapper.get());
    }

    public void testCustomObject()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "nestedObject");
        assertEquals(object.getClass(), wrapper.get().getClass());
    }

    public void testNestedReferences()
    {
        TestObject object = new TestObject();
        Kensho ken = new Kensho();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "nestedObject.shortNum");
        assertEquals((double)4, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "nestedObject.nestedObject.shortNum");
        assertEquals((double)4, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "string.len(nestedObject.stringHW) == 11");
        assertEquals(true, wrapper.get());
    }

    public void testObservable()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        object.observableValue = new ObservableValue(ken, 4.5);

        LuaWrapper wrapper = new LuaWrapper(ken, object, "observableValue + 5");
        assertEquals(4.5+5, wrapper.get());

        object.observableValue.set(9.2);
        assertEquals(9.2 + 5, wrapper.get());
    }

    public void testAdditionOperation()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        object.observableValue = new ObservableValue(ken, 4.5);

        LuaWrapper wrapper;

        wrapper = new LuaWrapper(ken, object, "5 + 4.5");
        assertEquals(4.5+5, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue + 5");
        assertEquals(4.5+5, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "5 + observableValue");
        assertEquals(4.5+5, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue + observableValue");
        assertEquals(4.5+4.5, wrapper.get());
    }

    public void testConcatenation()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        object.observableValue = new ObservableValue(ken, "AA");

        LuaWrapper wrapper;

        wrapper = new LuaWrapper(ken, object, "'AA'..'BB'");
        assertEquals("AABB", wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue .. 'BB'");
        assertEquals("AABB", wrapper.get());

        wrapper = new LuaWrapper(ken, object, "'BB' .. observableValue");
        assertEquals("BBAA", wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue .. observableValue");
        assertEquals("AAAA", wrapper.get());
    }

    public void testEquals()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        object.observableValue = new ObservableValue(ken, "AA");

        LuaWrapper wrapper;

        wrapper = new LuaWrapper(ken, object, "'AA' == 'AA'");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue == 'AA'");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "'AA' == observableValue");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue == observableValue");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue == 'BB'");
        assertEquals(false, wrapper.get());
    }

    public void testLessThan()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        object.observableValue = new ObservableValue(ken, 4.5);

        LuaWrapper wrapper;

        wrapper = new LuaWrapper(ken, object, "4.5 < 5");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue < 5");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "4 < observableValue");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue <= observableValue");
        assertEquals(true, wrapper.get());

        wrapper = new LuaWrapper(ken, object, "observableValue < 3");
        assertEquals(false, wrapper.get());
    }

    public void testConstructedObject()
    {
        Kensho ken = new Kensho();

        TestObject object = new TestObject();
        LuaWrapper wrapper = new LuaWrapper(ken, object, "{ name='myname', value=4.5, yes=true, no=false, sub={value=1} }");
        assertTrue(HashMap.class.isAssignableFrom(wrapper.get().getClass()));
        HashMap map = (HashMap)wrapper.get();
        assertEquals("myname", map.get("name"));
        assertEquals(4.5, map.get("value"));
        assertEquals(true, map.get("yes"));
        assertEquals(false, map.get("no"));
        assertTrue(HashMap.class.isAssignableFrom(map.get("sub").getClass()));
        HashMap subMap = (HashMap)map.get("sub");
        assertEquals(1.0, subMap.get("value"));

    }
}
