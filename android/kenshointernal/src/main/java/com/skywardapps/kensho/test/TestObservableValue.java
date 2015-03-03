package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;

/**
 * Created by nelliott on 2/23/15.
 */
public class TestObservableValue extends InstrumentationTestCase implements IObserver
{

    public void testConstruction()
    {
        Kensho ken = new Kensho();
        ObservableValue value = new ObservableValue(ken);
        assertNotNull(value);
    }

    public void testGetSet(){
        Object initialValue = 52;
        Object secondValue = "Hello World";
        Object initialResult = null;
        Object secondResult = null;

        Kensho ken = new Kensho();
        ObservableValue value = new ObservableValue(ken);

        value.set(initialValue);
        initialResult = value.get();

        value.set(secondValue);
        secondResult = value.get();

        assertEquals(initialValue, initialResult);
        assertEquals(secondValue, secondResult);
    }

    public void testNotificationEmitted(){
        Kensho ken = new Kensho();
        ObservableValue value = new ObservableValue(ken);

        // test null -> null, null -> value, value -> value, value -> value2, value2 -> null
        int value1 = 52;
        String value2 = "Hello World";

        value.set(null);
        value.addObserver(this);

        // null -> null
        valueChanged = false;
        value.set(null);
        assertFalse(valueChanged);

        // null -> value
        valueChanged = false;
        value.set(value1);
        assertTrue(valueChanged);

        // value -> value
        valueChanged = false;
        value.set(value1);
        assertFalse(valueChanged);

        // value -> value2
        valueChanged = false;
        value.set(value2);
        assertTrue(valueChanged);

        // value2 -> null
        valueChanged = false;
        value.set(null);
        assertTrue(valueChanged);
    }


    boolean valueChanged = false;
    public void observedValueChanged(IObservable valueHolder, Object newValue)
    {
        valueChanged = true;
    }
}
