package com.example.flutterhello;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

public class UserPresentBroadcastReceiver extends BroadcastReceiver {


    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onReceive(Context context, Intent intent) {
        //this also
        actOnBootCompleted(context, intent);

        //this is not working properly
        if (startServiceIfNotRunning(context, intent)) {
            return;
        }

        if (intent.getAction().equals(Intent.ACTION_USER_PRESENT)) {
            SQLiteDatabaseHandler db = new SQLiteDatabaseHandler(context);
            Toast.makeText(context, "lecimydalej dodajemy", Toast.LENGTH_LONG).show();

            db.addRecordToDb();
            setResult(1, "success", Bundle.EMPTY);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private void actOnBootCompleted(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Toast.makeText(context, "boot completed wjechalooo", Toast.LENGTH_LONG).show();
            Intent startAppIntent = new Intent(context, ForegroundService.class);

            context.startForegroundService(intent);
            Log.i("Autostart", "started");
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private boolean startServiceIfNotRunning(Context context, Intent intent) {
        if (!ForegroundService.isInstanceCreated() && (!MainActivity.active || !MainActivity.isActivityPaused())) {
            SQLiteDatabaseHandler db = new SQLiteDatabaseHandler(context);
            Intent startAppIntent = new Intent(context, ForegroundService.class);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(startAppIntent);
            } else {
                context.startService(startAppIntent);
            }

            Toast.makeText(context, "lecimydalej dodajemy", Toast.LENGTH_LONG).show();

            db.addRecordToDb();
            setResult(1, "success", Bundle.EMPTY);
            return true;
        }
        return false;
    }


}