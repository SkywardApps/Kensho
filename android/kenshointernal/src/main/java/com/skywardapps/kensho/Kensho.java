package com.skywardapps.kensho;

import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import com.skywardapps.kensho.bindings.EditTextBindingFactory;
import com.skywardapps.kensho.bindings.TextViewBinding;
import com.skywardapps.kensho.bindings.TextViewBindingFactory;

import java.util.Dictionary;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Stack;

/**
 * The master object, responsible for managing all the interactions between observables and
 * observers, and binding them to views.
 *
 * This object must typically be created first, as all binding and dependency tracking goes
 * through here.
 *
 * The general workflow is:
 *  Create Kensho object
 *  Register any Binding factories
 *  Create a model
 *  Apply bindings of that model to a view hierarchy
 *
 * Created by nelliott on 2/23/15.
 */
public class Kensho
{
    private Stack<HashSet<IObservable>> _trackingStack = new Stack<HashSet<IObservable>>();
    private Hashtable<Class, Hashtable<String, IBindingFactory>> _bindingFactory = new Hashtable<Class, Hashtable<String, IBindingFactory>>();
    private Hashtable<View, HashSet<IBinding>> _assignedBindings = new Hashtable<View, HashSet<IBinding>>();

    /**
     * A helper utility method to get the current object as a value, or get the value
     * from within an IObservable if it is one.
     *
     * This is primarily helpful in situations where we're evaluating lua, and don't know if
     * we're getting base an observable (eg 'name') or an evaluated value ('name .. "!"' or '5')
     * @param value The object to potentialy unwrap.
     * @return The final value after unwrapping.
     */
    public static Object unwrap(Object value)
    {
        if(value == null)
            return null;

        if(IObservable.class.isAssignableFrom(value.getClass()))
        {
            return ((IObservable)value).get();
        }

        return value;
    }

    /**
     * A helper utility method to create an observable value bound to this kensho.
     * @return A new observable value container
     */
    public ObservableValue observable(){
        return new ObservableValue(this);
    }

    /**
     * A helper utility method to create an observable value bound to this kensho.
     * @param initialValue The initial value
     * @return A new observable value container set to contain the initial value
     */
    public ObservableValue observable(Object initialValue){
        return new ObservableValue(this, initialValue);
    }

    /**
     * Standard constructor
     */
    public Kensho(){
        // Do we need to do a global reflection here to find every class that implements IBindingFactory?
        TextViewBindingFactory tvbf = new TextViewBindingFactory();
        registerBindingFactory(TextView.class, "text", tvbf);
        registerBindingFactory(TextView.class, "visible", tvbf);
        registerBindingFactory(TextView.class, "animateIn", tvbf);
        registerBindingFactory(TextView.class, "animateOut", tvbf);
        registerBindingFactory(EditText.class, "value", new EditTextBindingFactory());
    }

    public void registerBindingFactory(Class viewClass, String bindType, IBindingFactory factory)
    {
        if(!_bindingFactory.containsKey(viewClass))
        {
            _bindingFactory.put(viewClass, new Hashtable<String, IBindingFactory>());
        }

        _bindingFactory.get(viewClass).put(bindType, factory);
    }

    /**
     * Instruct the kensho to start tracking IObservable accesses.
     *
     * This is a stack based system, so you may nest calls.
     */
    public void startTrackingReferences()
    {
        _trackingStack.push(new HashSet<IObservable>());
    }

    /**
     * Notify kensho that an observable was referenced.
     * @param ref The observable whose value was retrieved
     */
    public void observableReferenced(IObservable ref)
    {
        if(_trackingStack.size() > 0)
        {
            _trackingStack.peek().add(ref);
        }
    }

    /**
     * Instruct the kensho to stop tracking references, and return all observables accessed
     * since the tracking began.
     * @return A set of Observables.
     */
    public HashSet<IObservable> endTrackingReferences()
    {
        if(_trackingStack.size() == 0)
        {
            throw new IllegalStateException("Tracking stack is empty when an end was requested");
        }
        return _trackingStack.pop();
    }


    /**
     * Entry method to bind a model's values to a view hierarchy
     * @param rootView The root view of the hierarchy to bind
     * @param model The root data object of the model to bind
     */
    public void applyBindings(View rootView, Object model)
    {
        Context coreContext = new Context(this, model, null, null);
        bindToView(rootView, coreContext);
    }

    /**
     * Unbind the model references from a view and its subviews.
     *
     * This can be helpful in two situations - if for some reason you are switching out a model,
     * but re-using the same views, and
     * If there are circular references and memory constraints.
     *
     * @param view The view to remove bindings from.
     */
    public void unbind(View view)
    {
        if(!_assignedBindings.containsKey(view))
            return;

        for(IBinding binding : _assignedBindings.get(view))
        {
            binding.unbind();
        }

        _assignedBindings.remove(view);


        if(view instanceof ViewGroup)
        {
            ViewGroup group = (ViewGroup)view;
            int count = group.getChildCount();
            for(int i = 0; i < count; ++i)
            {
                View subView = group.getChildAt(i);
                this.unbind(subView);
            }
        }
    }

    public void registerBinding(Class viewClass, String type, IBindingFactory factory){

        if(_bindingFactory.containsKey(viewClass)){
            _bindingFactory.get(viewClass).put(type, factory);
        } else {
            Hashtable<String, IBindingFactory> temp = new Hashtable<String, IBindingFactory>();
            temp.put(type, factory);
            _bindingFactory.put(viewClass, temp);
        }
    }

    public void setAttributeGroup(int[] grp){
        AttributeParser.setAttributeGroupName(grp);
    }

    /**
     * The internal recursive method for assigning out bindings to views.
     * @param currentView  The current view in the hierarchy
     * @param initialContext The context for the data binding
     */
    protected void bindToView(View currentView, Context initialContext)
    {
        Context currentContext = initialContext;

        // Make sure there's a container for the bindings on this view
        _assignedBindings.put(currentView, new HashSet<IBinding>());

        if(currentView.getId() > 0) {
            Dictionary<String, String> bindings = AttributeParser.getAttributesForView(currentView.getId());
            Enumeration<String> keys = bindings.keys();
            while (keys.hasMoreElements()) {
                String bindType = keys.nextElement(); // The attribute name, eg 'title' or 'fontSize'
                String bindValue = bindings.get(bindType); // The lua script

                // Now find the binding for this view's class, for this bindType
                // We start at the most specific derived class, and ascend up the inheritance tree
                // to try and find a match
                for (Class currentClass = currentView.getClass();
                     currentClass != null;
                     currentClass.getSuperclass()) {

                    if (!_bindingFactory.containsKey(currentClass))
                        continue;

                    if (!_bindingFactory.get(currentClass).containsKey(bindType))
                        continue;

                    // Create the binding factory, and then generate the actual binding
                    IBindingFactory factory = _bindingFactory.get(currentClass).get(bindType);

                    if (factory == null)
                        continue;

                    // Create the lua interpreter for this script
                    LuaWrapper wrapper = new LuaWrapper(this, currentContext, bindValue);

                    // Create the binding for this view type
                    IBinding binding = factory.create(currentView, bindType, currentContext, wrapper);

                    if (binding == null)
                        continue;

                    // Register this binding against this view
                    _assignedBindings.get(currentView).add(binding);
                    break;
                }
            }
        }

        // If this view has subviews, recursively assign them!
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
