package com.skywardapps.kensho.bindings;

import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.skywardapps.kensho.BindingBase;
import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.IBinding;
import com.skywardapps.kensho.IBindingFactory;
import com.skywardapps.kensho.IWritableObservable;
import com.skywardapps.kensho.LuaWrapper;

/**
 * Created by nelliott on 3/9/15.
 */
public class EditTextBindingFactory implements IBindingFactory {
    @Override
    public IBinding create(View view, String bindType, Context context, LuaWrapper value) {

        if(bindType.equals("value")) {
            return new EditTextBinding(view, bindType, context, value);
        };

        return null;
    }
}
