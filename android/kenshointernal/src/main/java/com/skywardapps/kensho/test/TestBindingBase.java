package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.BindingBase;
import com.skywardapps.kensho.IBinding;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.LuaWrapper;
import com.skywardapps.kensho.ObservableValue;

/**
 * Created by nelliott on 3/9/15.
 */
public class TestBindingBase extends InstrumentationTestCase
{
    private boolean evaluationChanged;
    public ObservableValue basicValue;
    private Double evaluatedValue;

    public void testSimpleEvaluation() {
        Kensho ken = new Kensho();
        basicValue = new ObservableValue(ken, 4.0);

        IBinding binding = new BindingBase(null, null, null, new LuaWrapper(ken, this, "basicValue")) {
            @Override
            public void updateValue() {
                evaluationChanged = true;
                evaluatedValue = (Double)this.getFinalValue();
            }
        };
        assertTrue(evaluationChanged);
        assertEquals(4.0, evaluatedValue);
    }

    public void testDirectValueChanged(){

        Kensho ken = new Kensho();
        basicValue = new ObservableValue(ken, 4.0);

        IBinding binding = new BindingBase(null, null, null, new LuaWrapper(ken, this, "basicValue")) {
            @Override
            public void updateValue() {
                evaluationChanged = true;
                evaluatedValue = (Double)this.getFinalValue();
            }
        };
        assertTrue(evaluationChanged);
        assertEquals(4.0, evaluatedValue);

        evaluationChanged = false;

        basicValue.set(6.0);
        assertTrue(evaluationChanged);
        assertEquals(6.0, evaluatedValue);
    }

    public void testEvaluatedValueChanged(){

        Kensho ken = new Kensho();
        basicValue = new ObservableValue(ken, 4.0);

        IBinding binding = new BindingBase(null, null, null, new LuaWrapper(ken, this, "basicValue + 5.5")) {
            @Override
            public void updateValue() {
                evaluationChanged = true;
                evaluatedValue = (Double)this.getFinalValue();
            }
        };
        assertTrue(evaluationChanged);
        assertEquals(9.5, evaluatedValue);

        evaluationChanged = false;

        basicValue.set(6.0);
        assertTrue(evaluationChanged);
        assertEquals(11.5, evaluatedValue);
    }
}
