package com.example.flutterhello;

import android.app.Service;
import android.content.Context;
import android.content.SharedPreferences;

public class Utils {

    private final String name = "SPYSERVICE_KEY";
    private final String key = "PYSERVICE_STATE";

    public void setServiceState(Context context, ServiceState state) {
        SharedPreferences sharedPrefs = getPreferences(context);
        SharedPreferences.Editor editor = sharedPrefs.edit();
        editor.putString(key, state.name());
        editor.apply();
    }

    public ServiceState getServiceState(Context context) {
        SharedPreferences sharedPrefs = getPreferences(context);
        String value = sharedPrefs.getString(key, ServiceState.STOPPED.name());
        return ServiceState.valueOf(value);
    }

    private SharedPreferences getPreferences(Context context) {
        return context.getSharedPreferences(name, 0);
    }
}
