package com.skywardapps.kensho;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashSet;

/**
 * Created by nelliott on 2/23/15.
 */
public abstract class Computed extends WatchableBase implements IObserver
{
    public Computed(Kensho kensho)
    {
        super(kensho);
        // Get the initial value
        trackCompute();
    }

    private ArrayList<WeakReference<IObservable>> _watched = new ArrayList<WeakReference<IObservable>>();

    protected abstract Object compute();

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

        for(IObservable observed : tracked)
        {
            observed.addObserver(this);
            _watched.add(new WeakReference<IObservable>(observed));
        }
    }

    public void observedValueChanged(IObservable valueHolder, Object newValue)
    {
        // A value we care about changed, so re-calculate our own value
        trackCompute();
    }
}
