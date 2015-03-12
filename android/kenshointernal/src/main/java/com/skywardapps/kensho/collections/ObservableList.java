package com.skywardapps.kensho.collections;

import android.support.annotation.NonNull;

import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

/**
 * Created by nelliott on 3/12/2015.
 */
public class ObservableList extends ObservableValue implements List
{
    public interface IListObserver extends IObserver
    {
        public void elementWasAddedToList(ObservableList collection, int index, Object value);
        public void elementWasRemovedFromList(ObservableList collection, int index, Object oldValue);
        public void elementWasReplacedInList(ObservableList collection, int index, Object newValue, Object oldValue);
        public void listWasCleared(ObservableList collection);
    }
    private ObservableValue _size;

    protected List getList()
    {
        return (List)super.get();
    }

    protected void updateSize()
    {
        _size.set(getList().size());
    }

    public ObservableList(Kensho ken)
    {
        super(ken, new ArrayList());
        _size = new ObservableValue(ken, 0);
    }

    public ObservableList(Kensho ken, List initialValue)
    {
        super(ken, initialValue);
        _size = new ObservableValue(ken, initialValue.size());
    }

    @Override public void set(Object newValue)
    {
        super.set(newValue);
        updateSize();
    }

    @Override
    public void add(int location, Object object) {
        getList().add(location, object);
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IListObserver))
                continue;

            IListObserver mapObserver = (IListObserver)observer;
            mapObserver.elementWasAddedToList(this, location, object);
        }
    }

    @Override
    public boolean add(Object object) {
        int location = getList().size();
        boolean result = getList().add(object);
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IListObserver))
                continue;

            IListObserver mapObserver = (IListObserver)observer;
            mapObserver.elementWasAddedToList(this, location, object);
        }
        return result;
    }

    @Override
    public boolean addAll(int location, Collection collection) {
        boolean addedAny = false;
        for(Object value : collection)
        {
            this.add(location, value);
            location++;
            addedAny = true;
        }
        return addedAny;
    }

    @Override
    public boolean addAll(Collection collection) {
        boolean addedAny = false;
        for(Object value : collection)
        {
            this.add( value);
            addedAny = true;
        }
        return addedAny;
    }

    @Override
    public void clear() {
        getList().clear();
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IListObserver))
                continue;

            IListObserver mapObserver = (IListObserver)observer;
            mapObserver.listWasCleared(this);
        }
    }

    @Override
    public boolean contains(Object object) {
        wasAccessed();
        return false;
    }

    @Override
    public Object get(int location) {
        wasAccessed();
        return getList().get(location);
    }

    @Override
    public int indexOf(Object object) {
        wasAccessed();
        return getList().indexOf(object);
    }

    @Override
    public boolean isEmpty() {
        wasAccessed();
        return getList().isEmpty();
    }

    @NonNull
    @Override
    public Iterator iterator() {
        wasAccessed();
        return getList().iterator();
    }

    @Override
    public int lastIndexOf(Object object) {
        wasAccessed();
        return getList().lastIndexOf(object);
    }

    @NonNull
    @Override
    public ListIterator listIterator() {
        wasAccessed();
        return getList().listIterator();
    }

    @NonNull
    @Override
    public ListIterator listIterator(int location) {
        wasAccessed();
        return getList().listIterator(location);
    }

    @Override
    public Object remove(int location) {
        Object result = getList().remove(location);
        updateSize();

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IListObserver))
                continue;

            IListObserver mapObserver = (IListObserver)observer;
            mapObserver.elementWasRemovedFromList(this, location, result);
        }

        return result;
    }

    @Override
    public boolean remove(Object object)
    {
        int location = getList().indexOf(object);
        if(location == -1)
            return false;

        this.remove(location);

        return true;
    }

    @Override
    public Object set(int location, Object object) {
        Object result = getList().set(location, object);

        for(WeakReference<IObserver> weakObserver : _observers)
        {
            IObserver observer = weakObserver.get();
            if(observer == null)
                continue;

            if(!(observer instanceof IListObserver))
                continue;

            IListObserver mapObserver = (IListObserver)observer;
            mapObserver.elementWasReplacedInList(this, location, object, result);
        }

        return result;
    }

    @Override
    public int size() {
        return (int)_size.get();
    }

    @NonNull
    @Override
    public List subList(int start, int end) {
        wasAccessed();
        return getList().subList(start, end);
    }

    @NonNull
    @Override
    public Object[] toArray() {
        wasAccessed();
        return getList().toArray();
    }

    @NonNull
    @Override
    public Object[] toArray(Object[] array) {
        wasAccessed();
        return getList().toArray(array);
    }

    @Override
    public boolean retainAll(Collection collection) {
        boolean modified = getList().retainAll(collection);
        updateSize();
        if(modified) {
            emitChangeNotification();
        }
        return modified;
    }

    @Override
    public boolean removeAll(Collection collection) {
        boolean modified = false;
        for(Object item : collection)
        {
            int location = getList().indexOf(item);
            if(location == -1)
                continue;
            modified = true;
            this.remove(location);
        }
        return modified;
    }

    @Override
    public boolean containsAll(Collection collection) {
        wasAccessed();
        return getList().containsAll(collection);
    }
}
