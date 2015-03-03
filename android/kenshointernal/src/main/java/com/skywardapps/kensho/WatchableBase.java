package com.skywardapps.kensho;

import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

/**
 * Created by nelliott on 2/23/15.
 */
public abstract class WatchableBase implements IObservable
{
    protected Kensho _ken;
    protected Object _value = null;
    protected ArrayList<WeakReference<IObserver>> _observers = new ArrayList<WeakReference<IObserver>>();

    public WatchableBase(Kensho kensho)
    {
        if(kensho == null)
        {
            throw new IllegalArgumentException("Kensho parameter cannot be null");
        }
        _ken = kensho;
    }

    public void addObserver(IObserver observer)
    {
        if(observer == null)
        {
            throw new IllegalArgumentException("Observer parameter cannot be null");
        }
        _observers.add(new WeakReference<IObserver>(observer));
    }

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

    public Object get()
    {
        _ken.observableReferenced(this);
        return _value;
    }

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
