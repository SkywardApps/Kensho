package com.skywardapps.kensho;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;

import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

public class AttributeParser {

    private AttributeParserFactory mFactory;
    private Map<Integer, HashMap<String, String>> mAttributeList;

    /**
     * This LayoutInflaterFactory intercepts the inflation of a view to gather up all the custom attributes into a hashmap
     * This function runs for each view that is inflated.
     */
    private class AttributeParserFactory implements LayoutInflater.Factory {
        @Override
        public View onCreateView(String name, Context context, AttributeSet attrs) {
            String id = attrs.getAttributeValue("http://schemas.android.com/apk/res/android", "id");

            // only continue if an id was set.
            // we could probably give this an id, if one was not set.
            if(id != null){
                // String with the reference character "@", so we strip it to keep only the reference
                id = id.replace("@", "");

                // find all of the custom attributes defined in the given attribute group (attrGrp)
                TypedArray attributeList = context.obtainStyledAttributes(attrs, getInstance().attrGrp);
                HashMap<String, String> attribute = new HashMap<>();
                int i = 0;

                for(int attr : attrGrp){
                    String attrname = context.getResources().getResourceEntryName(attr);
                    String attributeValue = attributeList.getString(i);

                    if(attributeValue != null)
                        attribute.put(attrname, attributeValue);

                    i++;
                }

                // put this attribute list in the hashmap with this view's id as key
                if(!attribute.isEmpty())
                    mAttributeList.put(Integer.valueOf(id), attribute);

                attributeList.recycle();
            }

            return null;
        }

    }

    private static AttributeParser mInstance;
    // the
    private int[] attrGrp;

    // this is a singleton, so keep the constructor private.
    private AttributeParser(){
        mAttributeList = new HashMap<>();
        mFactory = new AttributeParserFactory();
    }

    /**
     * Gets the instance of the AttributeParser object. Instantiates, if needed.
     * @return
     */
    private static AttributeParser getInstance(){
        if(mInstance == null){
            mInstance = new AttributeParser();
        }
        return mInstance;
    }

    /**
     * Sets the custom attribute group name
     * @param id The id of the custom attribute group
     */
    public static void setAttributeGroupName(int[] id){
        getInstance().attrGrp = id;
    }

    /**
     * The public facing layout inflater. Activities/Fragments must pass in the default layout
     * inflater and use the returned layout inflater to inflater their views in order to gain
     * access to their custom view attributes.
     * The attribute group property must be set prior to getting the layout inflater.
     * Throws an exception if the attribute group property is not set.
     * @param inflater The default layout inflater
     * @return The layout inflater with the custom attribute parser attached.
     * @throws com.skywardapps.kensho.AttributeParser.AttributeGroupNotSetException
     */
    public static LayoutInflater getLayoutInflater(LayoutInflater inflater) throws AttributeGroupNotSetException {
        if(getInstance().attrGrp == null){
            throw new AttributeGroupNotSetException();
        }
        return getInstance().getLayoutInflaterImpl(inflater);
    }

    /**
     * Returns the supplied layout inflater with the custom attribute parser added as a factory.
     * @param inflater
     * @return
     */
    private LayoutInflater getLayoutInflaterImpl(LayoutInflater inflater) {
        if(mFactory == null){
            mFactory = new AttributeParserFactory();
        }
        getInstance().mAttributeList.clear();
        LayoutInflater layoutInflater = inflater.cloneInContext(inflater.getContext());
        layoutInflater.setFactory(mFactory);

        return layoutInflater;
    }

    private Map<Integer, HashMap<String, String>> getAttributeList(){
        return getInstance().mAttributeList;
    }

    public static Dictionary<String, String> getAttributesForView(int viewId){
        Dictionary<String, String> result = new Hashtable<>(getInstance().getAttributeList().get(viewId));
        return result;
    }

    /**
     * Retrieves an attribute value given the view id and attribute id.
     * Throws an exception if the given attribute is not found in the attribute group
     * @param id - The id of the view
     * @param attribute - The attribute id
     * @return The attribute's value as a String
     * @throws com.skywardapps.kensho.AttributeParser.AttributeNotFoundInGroupException
     */
    public static String getAttributeForView(int id, int attribute) throws AttributeNotFoundInGroupException {
        String result = "";

        HashMap<String, String> attrs = getInstance().getAttributeList().get(id);

        // if the attribute id is not found, throw an exception
        if(attrs == null){
            throw new AttributeParser.AttributeNotFoundInGroupException(attribute);
        }

        // find the attribute's value and return it
        for(String k : attrs.keySet()){
            if(k.equals(attribute))
                result = attrs.get(k);
        }

        return result;
    }

    public static class AttributeGroupNotSetException extends RuntimeException {
        @Override
        public String getMessage() {
            return "Attribute group id must be set prior to getting the layout inflater";
        }
    }

    public static class AttributeNotFoundInGroupException extends RuntimeException {

        private int id;

        public AttributeNotFoundInGroupException(int id){
            this.id = id;
        }

        @Override
        public String getMessage() {
            return String.format("The id (%d) was not found in the attribute set.", this.id);
        }
    }

}

