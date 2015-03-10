package com.skywardapps.kenshotest;

import com.skywardapps.kensho.Computed;
import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IWritableObservable;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;

/**
 * Created by randyvalis on 3/4/15.
 */
public class MyModel {
    private ObservableValue _firstName;
    private ObservableValue _lastName;
    private Computed _fullName;

    public MyModel(Kensho ken)
    {
        _firstName = new ObservableValue(ken, "Nicholas");
        _lastName = new ObservableValue(ken, "Elliott");
        _fullName = new Computed(ken) {
            @Override
            protected Object compute() {
                return _firstName.get() + " " + _lastName.get();
            }
        };
    }

    public IWritableObservable firstName() { return _firstName; }
    public IWritableObservable lastName() {
        return _lastName;
    }
    public IObservable fullName() {
        return _fullName;
    }
}
