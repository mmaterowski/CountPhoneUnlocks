package com.example.flutterhello;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

public class UserPresentBroadcastReceiver extends BroadcastReceiver {

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onReceive(Context arg0, Intent intent) {

        /*Sent when the user is present after
         * device wakes up (e.g when the keyguard is gone)
         * */
         Toast.makeText(arg0,"lecimy",Toast.LENGTH_LONG).show();
        if(intent.getAction().equals(Intent.ACTION_USER_PRESENT)){
            SQLiteDatabaseHandler db = new SQLiteDatabaseHandler(arg0);
            Player player = new Player();
            Integer Min = 2;
            Integer Max=2000;
            player.setId(Min + (int)(Math.random() * ((Max - Min) + 1)));
            player.setName(LocalDateTime.now().toString());
            db.addPlayer(player);
           setResult(1,"success", Bundle.EMPTY);
        }
    }

}