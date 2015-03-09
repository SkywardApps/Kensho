package com.skywardapps.kensho;

import android.view.View;

/**
 * A factory object that can create bindings given a view and type.
 * Created by nelliott on 3/1/15.
 */
public interface IBindingFactory {
    /**
     * Create a new binding.
     * @param view The view to bind the data to.
     * @param bindType The type of binding.
     * @param context The context of the model being bound.
     * @param value The computed value to bind the view to.
     * @return A brand new binding object tying the value to the view.
     */
    public IBinding create(View view, String bindType, Context context, LuaWrapper value);
}
