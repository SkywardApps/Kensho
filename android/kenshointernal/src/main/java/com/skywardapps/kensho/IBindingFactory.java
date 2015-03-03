package com.skywardapps.kensho;

import android.view.View;

/**
 * Created by nelliott on 3/1/15.
 */
public interface IBindingFactory {
    public IBinding create(View view, String bindType, Context context, LuaWrapper value);
}
