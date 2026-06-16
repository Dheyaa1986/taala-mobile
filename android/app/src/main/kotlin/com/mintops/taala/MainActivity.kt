package com.mintops.taala

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationChannelHelper.ensureChannels(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ALERTS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "ensureChannels" -> {
                    NotificationChannelHelper.ensureChannels(this)
                    result.success(true)
                }
                "startKeepAlive" -> {
                    startKeepAliveService()
                    result.success(true)
                }
                "stopKeepAlive" -> {
                    stopService(Intent(this, TaalaAlertForegroundService::class.java))
                    result.success(true)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    result.success(requestIgnoreBatteryOptimizations())
                }
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "openVendorAutoStartSettings" -> {
                    result.success(DeviceVendorHelper.openAutoStartSettings(this))
                }
                "consumePendingFcmToken" -> {
                    result.success(consumePendingFcmToken())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startKeepAliveService() {
        val intent = Intent(this, TaalaAlertForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val manager = getSystemService(POWER_SERVICE) as PowerManager
        return manager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        if (isIgnoringBatteryOptimizations()) return true

        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun consumePendingFcmToken(): String? {
        val prefs = getSharedPreferences(TaalaFirebaseMessagingService.PREFS_NAME, Context.MODE_PRIVATE)
        val token = prefs.getString(TaalaFirebaseMessagingService.PENDING_FCM_TOKEN, null)
        if (!token.isNullOrBlank()) {
            prefs.edit().remove(TaalaFirebaseMessagingService.PENDING_FCM_TOKEN).apply()
        }
        return token
    }

    companion object {
        private const val ALERTS_CHANNEL = "com.mintops.taala/alerts"
    }
}
