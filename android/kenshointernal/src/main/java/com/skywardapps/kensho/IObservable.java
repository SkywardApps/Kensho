package com.skywardapps.kensho;

/**
 * Created by nelliott on 2/23/15.
 */
public interface IObservable
{
    void addObserver(IObserver observer);
    void removeObserver(IObserver observer);
    Object get();
}
