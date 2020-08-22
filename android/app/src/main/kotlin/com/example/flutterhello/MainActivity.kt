package com.example.flutterhello

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"
    private var resultLater: Result<String>? = null
    private var db: SQLiteDatabaseHandler? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerReceiver(UserPresentBroadcastReceiver(), IntentFilter());
        db = SQLiteDatabaseHandler(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "UserActiveChannel").setMethodCallHandler { call, result ->
            result.success(db !!.allPlayers().count());
        }

    }

    public fun getCount(): String {
        return db !!.allPlayers().count().toString();
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent !!.getIntExtra(BatteryManager.EXTRA_LEVEL, - 1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, - 1)
        }

        return batteryLevel
    }

}

