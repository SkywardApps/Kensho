package com.skywardapps.kensho;

/**
 * Created by nelliott on 3/1/15.
 */
public class Context
{
    private Kensho _ken;
    private Context _root;
    private Context _parent;
    private Object _context;

    public Context(Kensho ken, Object context, Context root, Context parent)
    {
        _ken = ken;
        _root = root;
        _parent = parent;
        _context = context;
    }

    public Context getRoot(){ return _root;}
    public Context getParent() { return _parent; }
    public Object getContext() { return _context; }
}
