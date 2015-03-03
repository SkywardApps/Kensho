package com.skywardapps.kensho;

import com.skywardapps.kensho.IObservable;

/**
 * Created by nelliott on 2/23/15.
 */
public interface IObserver
{
    void observedValueChanged(IObservable valueHolder, Object newValue);
}
