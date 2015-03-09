package com.skywardapps.kensho;

import com.skywardapps.kensho.IObservable;

/**
 * An object that can observe change notifications from an IObserver
 *
 * Created by nelliott on 2/23/15.
 */
public interface IObserver
{
    /**
     * Receive notification that the observed container's value has changed.
     *
     * @param valueHolder The observed container.
     * @param newValue The new value of the observed container.
     */
    void observedValueChanged(IObservable valueHolder, Object newValue);
}
