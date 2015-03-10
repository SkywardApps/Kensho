package com.skywardapps.kensho.bindings;

import android.view.View;
import android.widget.TextView;

import com.skywardapps.kensho.BindingBase;
import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.IBinding;
import com.skywardapps.kensho.IBindingFactory;
import com.skywardapps.kensho.LuaWrapper;

/**
 * Created by nelliott on 3/9/15.
 */
public class TextViewBindingFactory implements IBindingFactory
{
    @Override
    public IBinding create(View view, String bindType, Context context, LuaWrapper value) {
        if(bindType.equals("text")) {
            return new BindingBase(view, bindType, context, value) {
                @Override
                public void updateValue() {
                    TextView textView = (TextView) this.getView();
                    textView.setText((String) this.getFinalValue());
                }
            };
        };
        return null;
    }
}
