package com.example.flutterhello;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

public class ForegroundService extends Service {
    private static final String TAG = "MyService";

    private static ForegroundService instance = null;

    public static boolean isInstanceCreated() {
        return instance != null;
    }//met

    @Override
    public void onCreate() {
        instance = this;
    }//met

    @Override
    public void onDestroy() {
        Toast.makeText(this, "My Service Stopped", Toast.LENGTH_LONG).show();
        Log.d(TAG, "onDestroy");
        instance = null;
    }//met

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Intent dialogIntent = new Intent(this, MainActivity.class);
        dialogIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(dialogIntent);

        return flags;
    }

}
