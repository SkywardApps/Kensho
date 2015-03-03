package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashSet;

/**
 * Created by nelliott on 2/23/15.
 */
public class TestKensho extends InstrumentationTestCase implements IObservable
{
    public void testConstruction(){
        Kensho ken = new Kensho();
        assertNotNull(ken);
    }

    public void testTracking() {
        Kensho ken = new Kensho();
        ken.startTrackingReferences();
        ken.observableReferenced(this);
        ken.observableReferenced(this);
        HashSet<IObservable> results = ken.endTrackingReferences();
        assertEquals(1, results.size());
        assertTrue(results.contains(this));
    }


    @Override
    public void addObserver(IObserver observer) {

    }

    @Override
    public void removeObserver(IObserver observer) {

    }

    @Override
    public Object get() {
        return null;
    }
}
