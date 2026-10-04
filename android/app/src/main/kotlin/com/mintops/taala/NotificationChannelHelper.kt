package com.mintops.taala

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings

object NotificationChannelHelper {
    const val URGENT_CHANNEL_ID = "taala_urgent_orders_v2"
    private const val LEGACY_CHANNEL_ID = "taala_urgent_orders"

    private val vibrationPattern = longArrayOf(0, 500, 200, 500, 200, 800)

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        manager.deleteNotificationChannel(LEGACY_CHANNEL_ID)

        val ringtoneAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val urgent = NotificationChannel(
            URGENT_CHANNEL_ID,
            "طلبات ورسائل عاجلة",
            NotificationManager.IMPORTANCE_MAX,
        ).apply {
            description = "تنبيهات الطلبات والرسائل — مثل المكالمة"
            enableVibration(true)
            setVibrationPattern(this@NotificationChannelHelper.vibrationPattern)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setAllowBubbles(true)
            }
            setSound(Settings.System.DEFAULT_RINGTONE_URI, ringtoneAttributes)
        }

        manager.createNotificationChannel(urgent)
    }
}
