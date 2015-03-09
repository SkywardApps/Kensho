package com.skywardapps.kensho;

/**
 * Created by nelliott on 2/23/15.
 */
public class ObservableValue extends WatchableBase
{

    public ObservableValue(Kensho kensho)
    {
        super(kensho);
    }
    public ObservableValue(Kensho kensho, Object initialValue) {
        super(kensho);
        super.set(initialValue);
    }

    public void set(Object newValue)
    {
        super.set(newValue);
    }
}
