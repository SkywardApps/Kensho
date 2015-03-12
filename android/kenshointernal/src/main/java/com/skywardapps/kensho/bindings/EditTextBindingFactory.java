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
    public IBinding create(final View view, final String bindType, final Context context, final LuaWrapper value) {

        if(bindType.equals("value")) {
            final EditText textView = (EditText) view;
            textView.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {}

                @Override
                public void afterTextChanged(Editable s) {
                    if(IWritableObservable.class.isAssignableFrom(value.get().getClass()))
                    {
                        IWritableObservable o = (IWritableObservable)value.get();
                        o.set(textView.getText().toString());
                    }
                }
            });
            return new BindingBase(view, bindType, context, value) {
                @Override
                public void updateValue() {
                    if(!textView.getText().toString().equals(this.getFinalValue())) {
                        textView.setText(this.getFinalValue().toString());
                    }
                }
            };
        };

        return null;
    }
}
