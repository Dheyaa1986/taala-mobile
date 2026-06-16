package com.mintops.taala

import android.app.Application

class TaalaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        NotificationChannelHelper.ensureChannels(this)
    }
}
