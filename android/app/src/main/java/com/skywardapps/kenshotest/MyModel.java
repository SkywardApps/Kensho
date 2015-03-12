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
        aNumber = new ObservableValue(ken, 10.0);
        firstNameLength = new Computed(ken){

            @Override
            protected Object compute() {
                return firstName.get().toString().length();
            }
        };
        shouldShowHidden = new Computed(ken) {
            @Override
            protected Object compute() {
                int len = ((Integer)firstNameLength.get());
                return firstName.get().toString().length() > 10.0;
            }
        };
        shouldHideHidden = new Computed(ken) {
            @Override
            protected Object compute() {
                int len = ((Integer)firstNameLength.get());
                return firstName.get().toString().length() <= 10.0;
            }
        };

        innerModel = new ObservableValue(ken, new InnerModel(ken));
    }

    public final ObservableValue firstName;
    public final ObservableValue lastName;
    public final Computed fullName;
    public final ObservableValue aNumber;
    public final Computed firstNameLength;
    public final Computed shouldShowHidden;
    public final Computed shouldHideHidden;
    public final ObservableValue innerModel;

    class InnerModel {
        public String innerProperty;
        public InnerModel(Kensho ken){
            innerProperty = "Hello, from innerProperty";
        }
    }
}
