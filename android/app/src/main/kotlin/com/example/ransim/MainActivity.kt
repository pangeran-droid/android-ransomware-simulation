package com.example.ransim

import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Channel name for MethodChannel communication with Flutter
    private val CHANNEL = "com.simulasi.lockscreen/lock"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTask" -> handleStartLockTask(result)
                "stopLockTask" -> handleStopLockTask(result)
                else -> result.notImplemented()
            }
        }
    }

    // Activate Lock Task mode (Screen Pinning / Kiosk Mode)
    private fun handleStartLockTask(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                startLockTask() // Lock the system (Home and Recent Apps)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    // Exiting Lock Task mode (Unlocking the system)
    private fun handleStopLockTask(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                stopLockTask() // Releasing the lock
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }
}