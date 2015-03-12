package com.skywardapps.kensho.test;

import android.test.InstrumentationTestCase;

import com.skywardapps.kensho.Computed;
import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.collections.ObservableList;
import com.skywardapps.kensho.collections.ObservableMap;

import java.util.ArrayList;

/**
 * Created by nelliott on 3/12/2015.
 */
public class TestObservableList extends InstrumentationTestCase implements ObservableList.IListObserver
{
    int itemAdded = 0;
    int itemRemoved = 0;
    int itemReplaced = 0;
    int itemCleared = 0;
    int valueChanged = 0;

    public void setUp()
    {
        itemAdded = 0;
        itemRemoved = 0;
        itemReplaced = 0;
        itemCleared = 0;
        valueChanged = 0;
    }

    @Override
    public void elementWasAddedToList(ObservableList collection, int index, Object value) {
        itemAdded += (index+1);
    }

    @Override
    public void elementWasRemovedFromList(ObservableList collection, int index, Object oldValue) {
        itemRemoved += (index+1);
    }

    @Override
    public void elementWasReplacedInList(ObservableList collection, int index, Object newValue, Object oldValue) {
        itemReplaced += (index+1);
    }

    @Override
    public void listWasCleared(ObservableList collection) {
        itemCleared += 1;
    }

    @Override
    public void observedValueChanged(IObservable valueHolder, Object newValue) {
        valueChanged += 1;
    }

    public void testEmptyObservable()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken);
        list.add(0, "hello");
    }

    public void testAccessingOOB()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());
        list.add(0, "hello");
        Boolean invalid = false;
        try
        {
            list.get(5);
        }
        catch(IndexOutOfBoundsException ex)
        {
            invalid = true;
        }

        assertTrue(invalid);
    }

    public void testAppend()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());
        list.addObserver(this);

        list.add(0, "hello");

        assertEquals("hello", list.get(0));
        assertEquals(1, itemAdded);
        assertEquals(0, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(1,list.size());
    }

    public void testInsert()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());

        list.add(0, "hello");
        list.add(1, "world");

        list.addObserver(this);
        list.add(1, "dear");

        assertEquals("hello", list.get(0));
        assertEquals("dear", list.get(1));
        assertEquals("world", list.get(2));
        assertEquals(2, itemAdded);
        assertEquals(0, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(3,list.size());
    }

    public void testRemove()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());

        list.add(0, "hello");
        list.add(1, "dear");
        list.add(2, "world");

        list.addObserver(this);

        list.remove(1);

        assertEquals("hello", list.get(0));
        assertEquals("world", list.get(1));
        assertEquals(0, itemAdded);
        assertEquals(2, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(2,list.size());
    }

    public void testReplaceItem()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());

        list.add(0, "hello");
        list.add(1, "dear");
        list.add(2, "world");

        list.addObserver(this);

        list.set(1, "my");

        assertEquals("hello", list.get(0));
        assertEquals("my", list.get(1));
        assertEquals("world", list.get(2));
        assertEquals(0, itemAdded);
        assertEquals(0, itemRemoved);
        assertEquals(2, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(3,list.size());
    }

    public void testClear()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());

        list.add(0, "hello");
        list.add(1, "dear");
        list.add(2, "world");

        list.addObserver(this);

        list.clear();

        assertEquals(0, itemAdded);
        assertEquals(0, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(1, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(0, list.size());
    }

    public void testAddMultiple()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());
        ArrayList toAdd = new ArrayList();
        toAdd.add("dear");
        toAdd.add("world");

        list.add(0, "hello");

        list.addObserver(this);

        list.addAll(1, toAdd);

        assertEquals(5, itemAdded);
        assertEquals(0, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(3,list.size());
    }

    public void testRemoveMultiple()
    {
        Kensho ken = new Kensho();
        ObservableList list = new ObservableList(ken, new ArrayList());
        ArrayList toAdd = new ArrayList();
        toAdd.add("dear");
        toAdd.add("world");

        list.add(0, "hello");
        list.add(1, "dear");
        list.add(2, "world");

        list.addObserver(this);

        list.removeAll(toAdd);

        assertEquals(0, itemAdded);
        assertEquals(4, itemRemoved);
        assertEquals(0, itemReplaced);
        assertEquals(0, itemCleared);
        assertEquals(0, valueChanged);
        assertEquals(1, list.size());
    }


    public void testSizeChange()
    {
        Kensho ken = new Kensho();
        final ObservableList list = new ObservableList(ken, new ArrayList());

        list.add(0, "hello");
        list.add(1, "dear");
        list.add(2, "world");

        Computed sizeWatcher = new Computed(ken) {
            @Override
            protected Object compute() {
                return list.size();
            }
        };

        sizeWatcher.addObserver(new IObserver() {
            @Override
            public void observedValueChanged(IObservable valueHolder, Object newValue) {
                valueChanged += (int)newValue;
            }
        });

        list.remove(1);
        list.add(1);
        assertEquals(5, valueChanged);
        assertEquals(3, list.size());
    }
}
