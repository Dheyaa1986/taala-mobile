package com.mintops.taala

import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class TaalaAlertForegroundService : Service() {
    override fun onCreate() {
        super.onCreate()
        NotificationChannelHelper.ensureChannels(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationCompat.Builder(
            this,
            NotificationChannelHelper.KEEP_ALIVE_CHANNEL_ID,
        )
            .setContentTitle("طلاء")
            .setContentText("جاهز لاستقبال التنبيهات")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        startForeground(KEEP_ALIVE_NOTIFICATION_ID, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val KEEP_ALIVE_NOTIFICATION_ID = 1001
    }
}
