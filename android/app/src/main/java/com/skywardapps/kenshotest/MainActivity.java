package com.skywardapps.kenshotest;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.skywardapps.kensho.AttributeParser;
import com.skywardapps.kensho.IObservable;
import com.skywardapps.kensho.IObserver;
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
}
