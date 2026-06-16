import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taal/core/alerts/push_notification_service.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class AlertDeliveryBootstrap {
  AlertDeliveryBootstrap._();

  static const _channel = MethodChannel('com.mintops.taala/alerts');
  static bool _running = false;

  static Future<void> ensureReady() async {
    if (_running) return;
    _running = true;

    try {
      await PushNotificationService.instance.initialize();

      if (Platform.isAndroid) {
        await _channel.invokeMethod<void>('ensureChannels');
        await _ensureAndroidPermissions();
        await _syncPendingNativeToken();
        await _channel.invokeMethod<void>('startKeepAlive');
        await _openVendorSettingsOnce();
      }

      await PushNotificationService.instance.syncTokenIfLoggedIn();
    } finally {
      _running = false;
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stopKeepAlive');
    } catch (error) {
      debugPrint('stopKeepAlive failed: $error');
    }
  }

  static Future<void> _syncPendingNativeToken() async {
    try {
      final pending = await _channel.invokeMethod<String>('consumePendingFcmToken');
      if (pending != null && pending.isNotEmpty) {
        await PushNotificationService.instance.registerToken(pending);
      }
    } catch (error) {
      debugPrint('Pending FCM token sync failed: $error');
    }
  }

  static Future<void> _ensureAndroidPermissions() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    try {
      final ignoring = await _channel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      if (ignoring != true) {
        await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      }
    } catch (error) {
      debugPrint('Battery optimization request failed: $error');
    }
  }

  static Future<void> _openVendorSettingsOnce() async {
    final prompted = getIt<SharedPref>().get(
      key: PrefsKeys.alertVendorSetupDone,
    );
    if (prompted == true) return;

    try {
      await _channel.invokeMethod<bool>('openVendorAutoStartSettings');
      await getIt<SharedPref>().set(
        key: PrefsKeys.alertVendorSetupDone,
        value: true,
      );
    } catch (error) {
      debugPrint('Vendor autostart setup failed: $error');
    }
  }
}
