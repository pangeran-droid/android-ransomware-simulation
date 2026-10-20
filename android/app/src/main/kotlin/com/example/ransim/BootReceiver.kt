package com.example.ransim

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

// BroadcastReceiver to capture the signal when the device has finished restarting (Reboot)
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Check whether the received action is a boot-complete or quick-boot signal
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            // Create an intent to automatically call MainActivity in the background
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            context.startActivity(launchIntent)
        }
    }
}