package com.skywardapps.kensho.collections;

import android.support.annotation.NonNull;

import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;

import java.lang.ref.WeakReference;
import java.util.Collection;
import java.util.Map;
import java.util.Set;

/**
 * Created by nelliott on 3/12/2015.
 */
public class ObservableMap extends ObservableValue implements Map
{
    public interface IMapObserver extends IObserver
    {
        public void elementWasAddedToMap(ObservableMap collection, Object key, Object value);
        public void elementWasRemovedFromMap(ObservableMap collection, Object key);
        public void mapWasCleared(ObservableMap collection);
    }

    private ObservableValue _size;

    protected void updateSize()
    {
        _size.set(getMap().size());
    }

    protected Map getMap() {
        return (Map)super.get();
    }

    public ObservableMap(Kensho ken)
    {
        super(ken);
        _size = new ObservableValue(ken, 0);
    }

    public ObservableMap(Kensho ken, Map initialValue)
    {
        super(ken, initialValue);
        _size = new ObservableValue(ken, initialValue.size());
    }

    @Override
    public void set(Object newValue)
    {
        super.set(newValue);
        updateSize();
    }


    @Override
    public void clear() {
        getMap().clear();
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IMapObserver))
                continue;

            IMapObserver mapObserver = (IMapObserver)observer;
            mapObserver.mapWasCleared(this);
        }
    }

    @Override
    public boolean containsKey(Object key) {
        wasAccessed();
        return getMap().containsKey(key);
    }

    @Override
    public boolean containsValue(Object value) {
        wasAccessed();
        return getMap().containsValue(value);
    }

    @NonNull
    @Override
    public Set<Entry> entrySet() {
        wasAccessed();
        return getMap().entrySet();
    }

    @Override
    public Object get(Object key) {
        wasAccessed();
        return getMap().get(key);
    }

    @Override
    public boolean isEmpty() {
        wasAccessed();
        return getMap().isEmpty();
    }

    @NonNull
    @Override
    public Set keySet() {
        wasAccessed();
        return getMap().keySet();
    }

    @Override
    public Object put(Object key, Object value) {
        Object result = getMap().put(key, value);
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IMapObserver))
                continue;

            IMapObserver mapObserver = (IMapObserver)observer;
            mapObserver.elementWasAddedToMap(this, key, value);
        }

        return result;
    }

    @Override
    public void putAll(Map map) {
        for(Object key : map.keySet())
        {
            this.put(key, map.get(key));
        }
    }

    @Override
    public Object remove(Object key) {
        Object result = getMap().remove(key);
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IMapObserver))
                continue;

            IMapObserver mapObserver = (IMapObserver)observer;
            mapObserver.elementWasRemovedFromMap(this, key);
        }
        return result;
    }

    @Override
    public int size() {
        return (int)_size.get();
    }

    @NonNull
    @Override
    public Collection values() {
        wasAccessed();
        return getMap().values();
    }
}
