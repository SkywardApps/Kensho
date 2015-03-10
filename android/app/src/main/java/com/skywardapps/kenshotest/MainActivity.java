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
    Kensho ken;
    MyModel model;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        AttributeParser.setAttributeGroupName(R.styleable.KenshoAttr);
        LayoutInflater inflater = AttributeParser.getLayoutInflater(getLayoutInflater());
        View view = inflater.inflate(R.layout.activity_main, null);
        this.setContentView(view);

        Kensho ken = new Kensho();
        model = new MyModel(ken);

        ken.applyBindings(view, model);
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
