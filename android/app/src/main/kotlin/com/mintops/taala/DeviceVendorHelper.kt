package com.mintops.taala

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

object DeviceVendorHelper {
    fun openAutoStartSettings(context: Context): Boolean {
        val manufacturer = Build.MANUFACTURER?.lowercase().orEmpty()
        val intents = buildList {
            when {
                manufacturer.contains("xiaomi") || manufacturer.contains("redmi") -> {
                    add(
                        intent(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity",
                        ),
                    )
                    add(intent("com.miui.securitycenter", "com.miui.powercenter.PowerSettings"))
                }
                manufacturer.contains("huawei") || manufacturer.contains("honor") -> {
                    add(
                        intent(
                            "com.huawei.systemmanager",
                            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                        ),
                    )
                }
                manufacturer.contains("oppo") || manufacturer.contains("realme") -> {
                    add(
                        intent(
                            "com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.StartupAppListActivity",
                        ),
                    )
                }
                manufacturer.contains("vivo") -> {
                    add(
                        intent(
                            "com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity",
                        ),
                    )
                }
                manufacturer.contains("samsung") -> {
                    add(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = android.net.Uri.parse("package:${context.packageName}")
                    })
                }
            }
            add(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:${context.packageName}")
            })
        }

        for (target in intents) {
            target.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (target.resolveActivity(context.packageManager) != null) {
                context.startActivity(target)
                return true
            }
        }
        return false
    }

    private fun intent(packageName: String, className: String): Intent {
        return Intent().setComponent(ComponentName(packageName, className))
    }
}
