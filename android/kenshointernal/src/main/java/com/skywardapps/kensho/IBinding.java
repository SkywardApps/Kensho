package com.skywardapps.kensho;

/**
 * An object that can bind a data model (represented by an IObservable) to a view.
 *
 * Created by nelliott on 3/1/15.
 */
public interface IBinding {

    /**
     * Notify the binding that that model data has changed, and it must update the view.
     */
    public void updateValue();

    /**
     * Unbind the data from the view and release all references.
     */
    public void unbind();
}
