package com.skywardapps.kensho;

/**
 * An extention of the IObservable interface that allows writing back to the container.
 *
 * Created by nelliott on 3/9/15.
 */
public interface IWritableObservable extends IObservable
{
    /**
     * Update the value of the container.  This must cause a change event notification
     * if the value is different.
     *
     * @param newValue The new value for the observable container
     */
    void set(Object newValue);
}
