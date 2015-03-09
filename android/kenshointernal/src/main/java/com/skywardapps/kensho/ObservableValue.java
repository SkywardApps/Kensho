package com.skywardapps.kensho;

/**
 * The ObservableValue class is a basic read/write observable value container.
 *
 * Created by nelliott on 2/23/15.
 */
public class ObservableValue extends WatchableBase implements IWritableObservable
{
    /**
     * The basic constructor just requires the kensho owning manager.
     * @param kensho The kensho owning manager.
     */
    public ObservableValue(Kensho kensho)
    {
        super(kensho);
    }

    /**
     * A constructor that allows the caller to set the inital value
     * @param kensho The kensho owning manager.
     * @param initialValue The initial value the container is set to.
     */
    public ObservableValue(Kensho kensho, Object initialValue) {
        super(kensho);
        super.set(initialValue);
    }

    /**
     * A public setter that allows external access to set the value
     * @param newValue The new value the container is set to.
     */
    public void set(Object newValue)
    {
        super.set(newValue);
    }
}
