package com.example.flutterhello;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import java.util.List;

import org.jetbrains.annotations.NotNull;

public final class MainActivity extends FlutterActivity {
    private final String CHANNEL = "samples.flutter.dev/battery";
    private SQLiteDatabaseHandler db;

    static boolean active = false;

    public static boolean isActivityPaused() {
        return activityPaused;
    }

    public static void activityResumed() {
        activityPaused = false;
    }

    public static void activityPaused() {
        activityPaused = true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        MainActivity.activityResumed();
    }

    @Override
    protected void onPause() {
        super.onPause();
        MainActivity.activityPaused();
    }

    @Override
    public void onStart() {
        super.onStart();
        active = true;
    }

    @Override
    public void onStop() {
        super.onStop();
        active = false;
    }

    private static boolean activityPaused;

    public void configureFlutterEngine(@NonNull @NotNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        Toast.makeText(this, "rejestruje", Toast.LENGTH_LONG).show();
        IntentFilter intenFilter = new IntentFilter(Intent.CATEGORY_DEFAULT);
        intenFilter.addAction(Intent.ACTION_USER_PRESENT);
        intenFilter.addAction(Intent.ACTION_BOOT_COMPLETED);
        intenFilter.addAction(Intent.ACTION_SCREEN_ON);
        this.registerReceiver((BroadcastReceiver) (new UserPresentBroadcastReceiver()), intenFilter);
        this.db = new SQLiteDatabaseHandler((Context) this);
        DartExecutor dartExecutor = flutterEngine.getDartExecutor();
        (new MethodChannel(dartExecutor.getBinaryMessenger(), "UserActiveChannel")).setMethodCallHandler((MethodCallHandler) (new MethodCallHandler() {
            public final void onMethodCall(@NotNull MethodCall call, @NotNull io.flutter.plugin.common.MethodChannel.Result result) {
                SQLiteDatabaseHandler var10001 = MainActivity.this.db;
                List records = var10001.allPlayers();
                result.success(records.size());
            }
        }));
    }

    @NotNull
    public final String getCount() {
        return String.valueOf(this.db.allPlayers().size());
    }

}
