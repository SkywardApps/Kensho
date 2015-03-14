package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.Computed;
import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;

/**
 * Created by nelliott on 2/23/15.
 */
public class TestComputedValue extends InstrumentationTestCase implements IObserver
{
    // We want to test a basic value-returning compute
    public void testConstruction()
    {
        Kensho ken = new Kensho();
        Computed value = new Computed(ken){
            @Override
            protected Object compute() {
                return 52;
            }
        };
        assertNotNull(value);
        assertEquals(52, value.get());
    }

    // Test a observable-accessing compute (initial, no-change, change)
    public void testComputeReferencingObservable(){
        final Kensho ken = new Kensho();
        final ObservableValue value = new ObservableValue(ken, 5);
        final Computed computed = new Computed(ken) {
            @Override
            protected Object compute() {
                return Integer.parseInt(value.get().toString()) + 5;
            }
        };
        assertEquals(10, computed.get());

        computed.addObserver(this);
        valueChanged = false;
        value.set(20);
        assertTrue(valueChanged);
        assertEquals(25, computed.get());
    }

    // Test complex referencing with an if-statement
    public void testComputeConditionalLogic(){
        final Kensho ken = new Kensho();
        final ObservableValue logicGate = new ObservableValue(ken, false);
        final ObservableValue value1 = new ObservableValue(ken, 5);
        final ObservableValue value2 = new ObservableValue(ken, 9);

        final Computed computed = new Computed(ken) {
            @Override
            protected Object compute() {
                if((boolean)(Boolean)logicGate.get())
                {
                    return value2.get();
                }
                return value1.get();
            }
        };

        computed.addObserver(this);

        // make sure the initial computation is correct
        assertEquals(5, computed.get());

        // Now make sure that changing value1 triggers an update
        valueChanged = false;
        value1.set(6);
        assertTrue(valueChanged);
        assertEquals(6, computed.get());

        // Make sure changing value2 does not
        valueChanged = false;
        value2.set(10);
        assertFalse(valueChanged);
        assertEquals(6, computed.get());

        // Make sure that changing the logic gate triggers an update
        valueChanged = false;
        logicGate.set(true);
        assertTrue(valueChanged);
        assertEquals(10, computed.get());

        // Make sure that now, value 1 does not
        valueChanged = false;
        value1.set(7);
        assertFalse(valueChanged);
        assertEquals(10, computed.get());

        // And that value 2 does
        valueChanged = false;
        value2.set(11);
        assertTrue(valueChanged);
        assertEquals(11, computed.get());
    }

    boolean valueChanged = false;
    public void observedValueChanged(IObservable valueHolder, Object newValue)
    {
        valueChanged = true;
    }
}
