package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.LuaWrapper;
import com.skywardapps.kensho.ObservableValue;

/**
 *
 * Created by nelliott on 3/10/15.
 */
public class TestKenshoContext extends InstrumentationTestCase
{
    public class ContextTestModel
    {
        public ContextTestModel(Kensho ken, Object val)
        {
            testValue = ken.observable(val);
        }
        public ObservableValue testValue;
    }

    public void testPassThrough()
    {
        Kensho ken = new Kensho();
        ContextTestModel model = new ContextTestModel(ken, 1.5);
        Context context = new Context(ken, model, null, null);

        LuaWrapper script = new LuaWrapper(ken, context, "testValue");
        assertEquals(1.5, script.get());
    }

    public void testRoot()
    {
        Kensho ken = new Kensho();
        ContextTestModel model1 = new ContextTestModel(ken, 1.0);
        Context root = new Context(ken, model1, null, null);

        ContextTestModel model2 = new ContextTestModel(ken, 2.0);
        Context level2 = new Context(ken, model2, root, root);

        ContextTestModel model3 = new ContextTestModel(ken, 3.0);
        Context level3 = new Context(ken, model2, root, level2);

        LuaWrapper script = new LuaWrapper(ken, level3, "testValue");
        assertEquals(2.0, script.get());

        script = new LuaWrapper(ken, level3, "__root.testValue");
        assertEquals(1.0, script.get());
    }


    public void testParent()
    {

    }
}
