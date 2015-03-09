package com.skywardapps.kensho;

/**
 * A context is a wrapper for a model that provides structural information to the binding process.
 *
 * Contexts are stored as a stack, and can have parent contexts. Child access is not supported.
 *
 * Created by nelliott on 3/1/15.
 */
public class Context
{
    private Kensho _ken;
    private Context _root;
    private Context _parent;
    private Object _context;

    /**
     * Constructor that populates itself with basic required information
     *
     * @param ken The kensho managing object
     * @param context The model to bind
     * @param root The top of the context stack, if any
     * @param parent The parent context in the stack, if any
     */
    public Context(Kensho ken, Object context, Context root, Context parent)
    {
        _ken = ken;
        _root = root;
        _parent = parent;
        _context = context;
    }

    /**
     * Get the context at the root of the stack.
     * @return The context at the root of the stack.
     */
    public Context getRoot(){ return _root;}

    /**
     * Get the parent context above this one in the stack
     * @return The parent context
     */
    public Context getParent() { return _parent; }

    /**
     * Get the model data at this point in the stack.
     * @return The the model data at this point in the stack.
     */
    public Object getContext() { return _context; }
}
