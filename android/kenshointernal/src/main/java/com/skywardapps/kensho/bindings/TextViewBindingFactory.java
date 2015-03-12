package com.skywardapps.kensho.bindings;

import android.view.View;
import android.view.animation.AnimationUtils;
import android.widget.TextView;

import com.skywardapps.kensho.BindingBase;
import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.IBinding;
import com.skywardapps.kensho.IBindingFactory;
import com.skywardapps.kensho.LuaWrapper;
import com.skywardapps.kensho.R;

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
                    textView.setText(this.getFinalValue().toString());
                }
            };
        }
        else if(bindType.equals("visible")) {
            return new BindingBase(view, bindType, context, value) {
                @Override
                public void updateValue() {
                    TextView textView = (TextView) this.getView();
                    if((Boolean)this.getFinalValue())
                        textView.setVisibility(View.VISIBLE);
                    else
                        textView.setVisibility(View.INVISIBLE);
                }
            };
        }
        else if(bindType.equals("animateIn")) {
            return new BindingBase(view, bindType, context, value) {
                @Override
                public void updateValue() {
                    TextView textView = (TextView) this.getView();
                    Boolean val = (Boolean)this.getFinalValue();
                    if(val) {
                        textView.startAnimation(AnimationUtils.loadAnimation(textView.getContext(),
                                R.anim.text_view_animation));
                    }
                }
            };
        }
        else if(bindType.equals("animateOut")) {
            return new BindingBase(view, bindType, context, value) {
                @Override
                public void updateValue() {
                    TextView textView = (TextView) this.getView();
                    Boolean val = (Boolean)this.getFinalValue();
                    if(val) {
                        textView.startAnimation(AnimationUtils.loadAnimation(textView.getContext(),
                                R.anim.text_view_fade_out));
                    }
                }
            };
        }
        return null;
    }
}
