package com.example.flutterhello;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

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

//        AutoStartHelper.getInstance().getAutoStartPermission(this);
        actionOnService(Actions.START);

//        IntentFilter intenFilter = new IntentFilter(Intent.CATEGORY_DEFAULT);
//        intenFilter.addAction(Intent.ACTION_BOOT_COMPLETED);
//        intenFilter.addAction(Intent.ACTION_SCREEN_ON);
//        this.registerReceiver((BroadcastReceiver) (new UserPresentBroadcastReceiver()), intenFilter);
        this.db = new SQLiteDatabaseHandler((Context) this);
        DartExecutor dartExecutor = flutterEngine.getDartExecutor();
        (new MethodChannel(dartExecutor.getBinaryMessenger(), "UserActiveChannel")).setMethodCallHandler((MethodCallHandler) (new MethodCallHandler() {
            public final void onMethodCall(@NotNull MethodCall call, @NotNull io.flutter.plugin.common.MethodChannel.Result result) {
                SQLiteDatabaseHandler var10001 = MainActivity.this.db;
                List records = var10001.allPlayers();
                String jsonString = new Gson().toJson(records);
                result.success(jsonString);
            }
        }));
    }

    private void addAutoStartup() {

        try {
            Intent intent = new Intent();
            String manufacturer = android.os.Build.MANUFACTURER;
            if ("xiaomi".equalsIgnoreCase(manufacturer)) {
                intent.setComponent(new ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"));
            } else if ("oppo".equalsIgnoreCase(manufacturer)) {
                intent.setComponent(new ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"));
            } else if ("vivo".equalsIgnoreCase(manufacturer)) {
                intent.setComponent(new ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"));
            } else if ("Letv".equalsIgnoreCase(manufacturer)) {
                intent.setComponent(new ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity"));
            } else if ("Honor".equalsIgnoreCase(manufacturer)) {
                intent.setComponent(new ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"));
            }

            List<ResolveInfo> list = getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
            if  (list.size() > 0) {
                startActivity(intent);
            }
        } catch (Exception e) {
            Log.e("exc" , String.valueOf(e));
        }
    }

    private void actionOnService(Actions action) {
        if (new Utils().getServiceState(this) == ServiceState.STOPPED && action == Actions.STOP)
            return;

        Intent startServiceIntent = new Intent(this, EndlessService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(startServiceIntent);
        } else {
            startService(startServiceIntent);
        }
    }


    @NotNull
    public final String getCount() {
        return String.valueOf(this.db.allPlayers().size());
    }

}
