package com.skywardapps.kensho.bindings;

import android.app.Activity;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.IBinding;
import com.skywardapps.kensho.IBindingFactory;
import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
import com.skywardapps.kensho.LuaWrapper;

/**
 * Created by randyvalis on 3/6/15.
 */
public class TextViewBinding implements IBindingFactory, IObserver {

    TextView tv;
    Activity activity;
    String bindType;

    public TextViewBinding(Activity activity){
        this.activity = activity;
    }

    @Override
    public IBinding create(final View view, final String bindType, final Context context, final LuaWrapper value) {
        return new IBinding() {
            @Override
            public void updateValue() {
                tv = (TextView)view;
                value.addObserver(TextViewBinding.this);
                TextViewBinding.this.bindType = bindType.substring(bindType.lastIndexOf("/")+1);
            }

            @Override
            public void unbind() {
            }
        };
    }

    @Override
    public void observedValueChanged(IObservable valueHolder, final Object newValue) {

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (TextViewBinding.this.bindType.equals("text")) {
                    if(newValue instanceof IObservable)
                        tv.setText(((IObservable)newValue).get().toString());
                    else
                    tv.setText(newValue.toString());
                }
                else if (TextViewBinding.this.bindType.equals("textSize")) {
                    tv.setTextSize(((Double) newValue).floatValue());
                } else if (TextViewBinding.this.bindType.equals("textColor")) {
                    tv.setTextColor(Color.parseColor(newValue.toString()));
                }
            }
        });

    }
}
