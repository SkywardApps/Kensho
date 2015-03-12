package com.skywardapps.kensho.bindings;

import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

import com.skywardapps.kensho.BindingBase;
import com.skywardapps.kensho.Context;
import com.skywardapps.kensho.IWritableObservable;
import com.skywardapps.kensho.LuaWrapper;

/**
 * Created by nelliott on 3/10/15.
 */
public class EditTextBinding extends BindingBase implements TextWatcher
{
    private EditText _textView;
    private LuaWrapper _value;

    public EditTextBinding(View view, String bindType, Context context, LuaWrapper value)
    {
        super(view, bindType, context, value);

        _textView = (EditText)view;
        _value = value;

        _textView.addTextChangedListener(this);
    }

    @Override
    public void unbind()
    {
        super.unbind();
        _textView.removeTextChangedListener(this);
        _textView = null;
        _value = null;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {}

    @Override
    public void afterTextChanged(Editable s) {
        if(_value.get() != null && IWritableObservable.class.isAssignableFrom(_value.get().getClass()))
        {
            IWritableObservable o = (IWritableObservable)_value.get();
            o.set(_textView.getText().toString());
        }
    }

    @Override
    public void updateValue() {
        if(!_textView.getText().toString().equals(this.getFinalValue())) {
            _textView.setText((String) this.getFinalValue());
        }
    }
}
