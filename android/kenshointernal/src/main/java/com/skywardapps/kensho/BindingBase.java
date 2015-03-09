package com.skywardapps.kensho;

import android.view.View;

/**
 * The BindingBase class is a utility class that bindings can choose to extend in order
 * to get some basic functionality.
 *
 * The BindingBase class will handle all the relevant observations, registering and unregistering,
 * on your behalf.
 *
 * The helper method getFinalValue also acts as a kind of 'unwrap', allowing you to simply access the final value, and not
 * worry about whether the lua evaluated to an observable or a simple value.
 */
public abstract class BindingBase implements IBinding, IObserver
{
    private LuaWrapper _value;
    private IObservable _valueOutput;
    private String _bindType;
    private Context _context;
    private View _view;

    /**
     * Basic constructor method
     * @param view The view that the binding should bind to.
     * @param bindType The textual name of the attribute the binding is for.
     * @param context The model the binding was invoked in the context of.  Optional in the sense that this base class does not use it.
     * @param value The LuaWrapper to evaluate for the binding data.
     */
    public BindingBase(View view, String bindType, Context context, LuaWrapper value)
    {
        _value = value;
        _value.addObserver(this);
        _bindType = bindType;
        _context = context;
        _view = view;
    }

    /**
     * Access the view this is bound to.
     * @return The view this is bound to.
     */
    protected View getView(){
        return _view;
    }

    /**
     * Access the model and context this binding was invoked for.
     * @return The context this binding was invoked within.
     */
    protected Context getContext(){
        return _context;
    }

    /**
     * Access the final value to be used for this binding.
     * @return The final value - unwrapped if necessary.
     */
    protected Object getFinalValue() {
        if(_valueOutput != null)
        {
            return _valueOutput.get();
        }
        return _value.get();
    }


    /**
     * Track the changes to the lua script or the returned observables.
     * @param valueHolder The observable that changed
     * @param newValue The new value
     */
    public void observedValueChanged(IObservable valueHolder, Object newValue)
    {
        // We track observables that come out of the lua script, but go no deeper.
        if(valueHolder == _value && _valueOutput != newValue)
        {
            // If the previous value was an observable, de-register ourselves
            if (_valueOutput != null
                    && _valueOutput != newValue && IObservable.class.isAssignableFrom(_valueOutput.getClass())) {
                _valueOutput.removeObserver(this);
            }

            // If the new value is an observable, we want to register for its events
            if (newValue != null
                    && IObservable.class.isAssignableFrom(newValue.getClass()))
            {
                ((IObservable) newValue).addObserver(this);
                _valueOutput = (IObservable) newValue;
            }
            else
            {
                // We don't bother storing the output if we don't observe it
                _valueOutput = null;
            }
        }
        this.updateValue();
    }

    @Override
    public void unbind() {
        // Default implementation
        if(_valueOutput != null)
        {
            _valueOutput.removeObserver(this);
        }
        _value.removeObserver(this);

        _valueOutput = null;
        _value = null;
        _view = null;
        _context = null;
    }
}

