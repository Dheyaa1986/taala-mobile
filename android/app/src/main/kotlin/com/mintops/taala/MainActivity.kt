package com.mintops.taala

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(wrapWithMapLocale(newBase, readSavedMapLanguage(newBase)))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationChannelHelper.ensureChannels(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MAPS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "googleMapsApiKey" -> result.success(readGoogleMapsApiKey())
                "setMapLanguage" -> {
                    val code = call.arguments as? String ?: "ar"
                    applyMapLanguage(code)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ALERTS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "ensureChannels" -> {
                    NotificationChannelHelper.ensureChannels(this)
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
                "consumeLaunchNotificationPayload" -> {
                    val payload = TaalaFirebaseMessagingService.extractNotificationPayload(intent)
                    TaalaFirebaseMessagingService.clearNotificationPayload(intent)
                    result.success(payload)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
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
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun applyMapLanguage(languageCode: String) {
        val locale = localeForMap(languageCode)
        Locale.setDefault(locale)
        val config = Configuration(resources.configuration)
        config.setLocale(locale)
        @Suppress("DEPRECATION")
        resources.updateConfiguration(config, resources.displayMetrics)
    }

    private fun wrapWithMapLocale(base: Context, languageCode: String): Context {
        val locale = localeForMap(languageCode)
        Locale.setDefault(locale)
        val config = Configuration(base.resources.configuration)
        config.setLocale(locale)
        return base.createConfigurationContext(config)
    }

    private fun readSavedMapLanguage(base: Context): String {
        val prefs = base.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val selected = prefs.getString("flutter.selected_language", null)
        val easyLocale = prefs.getString("flutter.locale", null)
        val raw = selected ?: easyLocale ?: "ar"
        return raw.take(2).ifEmpty { "ar" }
    }

    private fun localeForMap(languageCode: String): Locale {
        return if (languageCode.startsWith("en")) Locale.ENGLISH else Locale("ar")
    }

    private fun readGoogleMapsApiKey(): String {
        return try {
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getApplicationInfo(
                    packageName,
                    PackageManager.ApplicationInfoFlags.of(
                        PackageManager.GET_META_DATA.toLong(),
                    ),
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getApplicationInfo(
                    packageName,
                    PackageManager.GET_META_DATA,
                )
            }
            info.metaData?.getString("com.google.android.geo.API_KEY").orEmpty()
        } catch (_: Exception) {
            ""
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
        private const val MAPS_CHANNEL = "com.mintops.taala/maps"
    }
}
