package com.skywardapps.kensho;

/**
 * An observable container.
 *
 * Can notify watchers, implementing the IObserver interface, when their contained data changed.
 *
 * Created by nelliott on 2/23/15.
 */
public interface IObservable
{
    /**
     * Register a watcher for this object.
     *
     * @param observer The object that will watch for change notifications.
     */
    void addObserver(IObserver observer);


    /**
     * Remove a previously registered watcher.
     *
     * @param observer The object that will no longer watch for change notifications.
     */
    void removeObserver(IObserver observer);


    /**
     * Return the value contained within this object.
     *
     * This must register the access with the kensho managing object, for reference tracking.
     *
     * @return The value contained, or null
     */
    Object get();
}
