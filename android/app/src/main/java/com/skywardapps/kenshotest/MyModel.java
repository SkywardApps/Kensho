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

    public MyModel(Kensho ken)
    {
        firstName = new ObservableValue(ken, "Nicholas");
        lastName = new ObservableValue(ken, "Elliott");
        fullName = new Computed(ken) {
            @Override
            protected Object compute() {

                return firstName.get() + " " + lastName.get();
            }
        };
    }

    public final ObservableValue firstName;
    public final ObservableValue lastName;
    public final Computed fullName;

}
