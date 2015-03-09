package com.skywardapps.kenshotest;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.skywardapps.kensho.AttributeParser;
import com.skywardapps.kensho.Kensho;
import com.skywardapps.kensho.ObservableValue;


public class MainActivity extends ActionBarActivity
{
    public String callback()
    {
        return "return \"Goodbye \"..\"cruel\"..\" world\";";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AttributeParser.setAttributeGroupName(R.styleable.KenshoAttr);
        LayoutInflater inflater = AttributeParser.getLayoutInflater(getLayoutInflater());
        View view = inflater.inflate(R.layout.activity_main, null);
        //setContentView(com.skywardapps.kenshotest.R.layout.activity_main);
        Kensho k = new Kensho();
        MyModel m = new MyModel();
        ObservableValue ov = k.observable();
        ov.set(m);
        m.setName("Hello");
        k.applyBindings(view.findViewById(R.id.textView), ov);
        //String j = testLua("return \"Hello \"..\"world\";");
        //Log.d("JNI", j);
    }

    /* A native method that is implemented by the
     * 'hello-jni' native library, which is packaged
     * with this application.
     */
    public native String  testLua(String loc);

    /* this is used to load the 'hello-jni' library on application
     * startup. The library has already been unpacked into
     * /data/data/com.skywardapps.hellojni/lib/libhello-jni.so at
     * installation time by the package manager.
     */
    static {
        //System.loadLibrary("lua");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(com.skywardapps.kenshotest.R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();


        return super.onOptionsItemSelected(item);
    }
}
