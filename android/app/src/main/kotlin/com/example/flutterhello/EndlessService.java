package com.example.flutterhello;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import android.widget.Toast;

import java.util.Random;

public class EndlessService extends Service {
    private static final String TAG = "MyService";
    private static final PowerManager.WakeLock wakeLock = null;
    private static EndlessService instance = null;
    private static boolean isServiceStarted = false;

    public static boolean isInstanceCreated() {
        return instance != null;
    }//met

    UserPresentBroadcastReceiver userPresentReceiver = new UserPresentBroadcastReceiver();

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        Notification notification = createNotification();
        startForeground(1, notification);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Toast.makeText(this, "My Service Stopped", Toast.LENGTH_LONG).show();
        unregisterReceiver((this.userPresentReceiver));
        instance = null;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
            IntentFilter intentFilter = new IntentFilter(Intent.CATEGORY_DEFAULT);
            intentFilter.addAction(Intent.ACTION_USER_PRESENT);
            intentFilter.addAction(Intent.ACTION_SCREEN_ON);
            this.registerReceiver(this.userPresentReceiver, intentFilter);

            this.startService();
            return START_STICKY;

        }

    private void startService() {
        if (isServiceStarted) return;
        Toast.makeText(this, "Service starting its task", Toast.LENGTH_SHORT).show();
        isServiceStarted = true;

        new Utils().setServiceState(this, ServiceState.STARTED);

        // we need this lock so our service gets not affected by Doze Mode
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "EndlessService::lock");
        wakeLock.acquire();

        IntentFilter intentFilter = new IntentFilter(Intent.CATEGORY_DEFAULT);
        intentFilter.addAction(Intent.ACTION_USER_PRESENT);
        intentFilter.addAction(Intent.ACTION_SCREEN_ON);
        this.registerReceiver(this.userPresentReceiver, intentFilter);
    }



        private Notification createNotification() {
            String notificationChannelId = "ENDLESS SERVICE CHANNEL";

            // depending on the Android API that we're dealing with we will have
            // to use a specific method to create the notification
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
                NotificationChannel channel = new NotificationChannel(
                        notificationChannelId,
                        "Endless Service notifications channel",
                        NotificationManager.IMPORTANCE_HIGH
                );
                channel.setDescription("Endless Service channel");
                channel.enableLights(true);
                channel.setLightColor(Color.RED);
                channel.enableVibration(true);
                channel.enableVibration(true);
                channel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});

                notificationManager.createNotificationChannel(channel);
            }
            Random generator = new Random();
            Intent notificationIntent = new Intent(this, MainActivity.class);
            PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

            Notification.Builder builder;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                builder = new Notification.Builder(this, notificationChannelId);
            } else {
                builder = new Notification.Builder(this);
            }
            builder.setContentTitle("Endless Service");
            builder.setContentText("This is your favorite endless service working");
            builder.setContentIntent(pendingIntent);
            builder.setSmallIcon(R.mipmap.ic_launcher);
            builder.setTicker("Ticker text");

            return builder.build();


        }
    }
