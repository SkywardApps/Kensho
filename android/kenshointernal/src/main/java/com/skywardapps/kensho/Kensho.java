package com.skywardapps.kensho;

import android.view.View;
import android.view.ViewGroup;

import java.util.Dictionary;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Stack;

/**
 * Created by nelliott on 2/23/15.
 */
public class Kensho
{
    public Kensho(){
        // Do we need to do a global reflection here to find every class that implements IBindingFactory?

    }

    private Stack<HashSet<IObservable>> _trackingStack = new Stack<>();
    private Hashtable<Class, Hashtable<String, IBindingFactory>> _bindingFactory = new Hashtable<>();
    private Hashtable<View, HashSet<IBinding>> _assignedBindings = new Hashtable<>();


    public void startTrackingReferences()
    {
        _trackingStack.push(new HashSet<IObservable>());
    }

    public void observableReferenced(IObservable ref)
    {
        if(_trackingStack.size() > 0)
        {
            _trackingStack.peek().add(ref);
        }
    }

    public HashSet<IObservable> endTrackingReferences()
    {
        if(_trackingStack.size() == 0)
        {
            throw new IllegalStateException("Tracking stack is empty when an end was requested");
        }
        return _trackingStack.pop();
    }

    public ObservableValue observable(){
        return new ObservableValue(this);
    }


    public void applyBindings(View rootView, Object model)
    {
        Context coreContext = new Context(this, model, null, null);
        bindToView(rootView, coreContext);
    }

    public void unbind(View view)
    {
        if(!_assignedBindings.containsKey(view))
            return;

        for(IBinding binding : _assignedBindings.get(view))
        {
            binding.unbind();
        }

        _assignedBindings.remove(view);
    }

    protected void bindToView(View currentView, Context initialContext)
    {
        Context currentContext = initialContext;

        _assignedBindings.put(currentView, new HashSet<IBinding>());

        Dictionary<String, String> bindings = null;
        Enumeration<String> keys = bindings.keys();
        while(keys.hasMoreElements())
        {
            String bindType = keys.nextElement();
            String bindValue = bindings.get(bindType);

            LuaWrapper wrapper = new LuaWrapper(this, currentContext, bindValue);

            // Now find the binding for this view's class, for this bindType
            for(Class currentClass = currentContext.getContext().getClass();
                currentClass != null;
                currentClass.getSuperclass()) {

                if(!_bindingFactory.containsKey(currentClass))
                    continue;

                if(!_bindingFactory.get(currentClass).containsKey(bindType))
                    continue;

                // Create the binding factory, and then generate the actual binding
                IBindingFactory factory = _bindingFactory.get(currentClass).get(bindType);
                IBinding binding = factory.create(currentView, bindType, currentContext, wrapper);

                // Register this binding against this view
                _assignedBindings.get(currentView).add(binding);

                binding.updateValue();
                break;
            }
        }

        if(currentView instanceof ViewGroup)
        {
            ViewGroup group = (ViewGroup)currentView;
            int count = group.getChildCount();
            for(int i = 0; i < count; ++i)
            {
                View subView = group.getChildAt(i);
                this.bindToView(subView, currentContext);
            }
        }
    }
}
