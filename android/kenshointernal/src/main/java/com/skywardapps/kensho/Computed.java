package com.skywardapps.kensho;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashSet;

/**
 * A calculated value, based of of observable values.
 *
 * This abstract class must be subclasses to be of any use.  Implement the compute method
 * and access the required observable values within it.  Any access will be tracked, and
 * this object will subsequently watch for changes on those observables.
 *
 * If the dependent values change and cause the computed value to change, this will send out a
 * change notification.  If the resulting value is no different, no notification will be sent, even
 * if the underlying data has changed.
 *
 * Created by nelliott on 2/23/15.
 */
public abstract class Computed extends WatchableBase implements IObserver
{
    /**
     * Basic constructor requires the kensho manager.
     * @param kensho the kensho manager.
     */
    public Computed(Kensho kensho)
    {
        super(kensho);
        // Get the initial value
        trackCompute();
    }

    private ArrayList<WeakReference<IObservable>> _watched = new ArrayList<WeakReference<IObservable>>();

    /**
     * This is the method that a subclass must implement to compute the final value.
     *
     * Accessing observable values within this method will be tracked, and used to register
     * for notifications of changes.  On a change of the dependent data, this method will be
     * invoked again.
     *
     * @return The computed value.
     */
    protected abstract Object compute();

    /**
     * Wrapper method for compute.
     *
     * This sets up the tracking before the method is invoked, and processes the access data
     * after the method has completed.
     */
    protected void trackCompute(){
        // We unregister everything we're watching
        for(int i = 0; i < _watched.size(); ++i)
        {
            IObservable observed = _watched.get(i).get();
            if(observed != null)
            {
                observed.removeObserver(this);
            }
        }
        _watched.clear();

        // Start tracking what we reference this time
        _ken.startTrackingReferences();

        // Now re-calculate the value
        super.set(compute());

        // Now get everything we referenced and track it
        HashSet<IObservable> tracked = _ken.endTrackingReferences();

        // Add ourselves as an observer for any accessed data
        for(IObservable observed : tracked)
        {
            observed.addObserver(this);
            _watched.add(new WeakReference<IObservable>(observed));
        }
    }

    /**
     * Implementation of the IObserver method to track dependent changes.
     * @param valueHolder The observable container that changed
     * @param newValue The new value of the observable container
     */
    public void observedValueChanged(IObservable valueHolder, Object newValue)
    {
        // A value we care about changed, so re-calculate our own value
        trackCompute();
    }
}
