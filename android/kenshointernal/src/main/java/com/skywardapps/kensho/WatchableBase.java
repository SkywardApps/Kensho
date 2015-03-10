package com.skywardapps.kensho;

import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

/**
 * The base Observable class, read-only.
 *
 * This implements the observable infrastructure, so for the most part any observable container
 * should extent this.
 * It handles registration of watchers and notification.  It has a protected setter, so
 * derived subclasses can change the value and cause a notification.
 * Created by nelliott on 2/23/15.
 */
public abstract class WatchableBase implements IObservable
{
    protected Kensho _ken;
    public Object _value = null;
    protected ArrayList<WeakReference<IObserver>> _observers = new ArrayList<WeakReference<IObserver>>();

    /**
     * The default constructor.
     * @param kensho The owning kensho manager
     */
    public WatchableBase(Kensho kensho)
    {
        if(kensho == null)
        {
            throw new IllegalArgumentException("Kensho parameter cannot be null");
        }
        _ken = kensho;
    }

    /**
     * Register a watcher for this object.
     *
     * A weak reference to the watcher will be taken.  This means that observing this object
     * will not cause the observer to remain -- you must take your own strong reference.
     * @param observer The object that will watch for change notifications.  Not retained.
     */
    public void addObserver(IObserver observer)
    {
        if(observer == null)
        {
            throw new IllegalArgumentException("Observer parameter cannot be null");
        }
        _observers.add(new WeakReference<IObserver>(observer));
    }

    /**
     * Remove a previously registered watcher.
     *
     * This will silently do nothing if the observer isn't actually watching for changes.
     * Currently this has a fairly poor performance profile.
     *
     * @param observer The object that will no longer watch for change notifications.
     */
    public void removeObserver(IObserver observer)
    {
        if(observer == null)
        {
            throw new IllegalArgumentException("Observer parameter cannot be null");
        }
        for(int i = _observers.size()-1; i >=0; --i)
        {
            IObserver match = _observers.get(i).get();
            if(match == null)
            {
                _observers.remove(i);
            }
            else if(match == observer)
            {
                _observers.remove(i);
                return;
            }
        }
    }

    /**
     * Return the value contained within this object.
     *
     * This will register the access with the kensho managing object, for reference tracking.
     *
     * @return The value contained, or null
     */
    public Object get()
    {
        _ken.observableReferenced(this);
        return _value;
    }

    /**
     * Set a new value to be contained within this object.
     *
     * This will notify watchers of the change, if the value is not the previous value.  If
     * the value has not changed, this is a no-op.
     *
     * @param newValue  The new value to be set to the container.
     */
    protected void set(Object newValue)
    {
        if((newValue == null && _value != null)
            || (newValue != null && _value == null)
                || (newValue != null && !newValue.equals(_value))) {
            _value = newValue;

            // let every watcher know
            for(int i = _observers.size()-1; i >= 0; --i)
            {
                IObserver observer = _observers.get(i).get();
                if(observer == null)
                {
                    _observers.remove(i);
                }
                else
                {
                    observer.observedValueChanged(this, newValue);
                }
            }
        }
    }
}
