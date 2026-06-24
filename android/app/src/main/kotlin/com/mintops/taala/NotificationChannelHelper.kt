package com.mintops.taala

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings

object NotificationChannelHelper {
    const val URGENT_CHANNEL_ID = "taala_urgent_orders"

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val urgent = NotificationChannel(
            URGENT_CHANNEL_ID,
            "طلبات ورسائل عاجلة",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "تنبيهات الطلبات والرسائل — مثل المكالمة"
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 300, 120, 300, 120, 400)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setAllowBubbles(true)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                setBypassDnd(true)
            }
            val soundUri = Settings.System.DEFAULT_NOTIFICATION_URI
            setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
        }

        manager.createNotificationChannel(urgent)
    }
}
