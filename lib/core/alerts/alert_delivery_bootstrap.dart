import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taal/core/alerts/push_notification_service.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/secure_local_storage.dart';

class AlertDeliveryBootstrap {
  AlertDeliveryBootstrap._();

  static const _channel = MethodChannel('com.mintops.taala/alerts');
  static bool _running = false;
  static bool _nativeExtrasScheduled = false;

  static Future<void> ensureReady() async {
    if (_running) return;
    _running = true;

    try {
      await PushNotificationService.instance.initialize();
      await PushNotificationService.instance.syncTokenIfLoggedIn();

      if (Platform.isIOS) {
        await _ensureIosPermissions();
      } else if (Platform.isAndroid) {
        _scheduleAndroidExtras();
      }
    } finally {
      _running = false;
    }
  }

  static void _scheduleAndroidExtras() {
    if (_nativeExtrasScheduled) return;
    _nativeExtrasScheduled = true;

    Future<void>.delayed(const Duration(seconds: 4), () async {
      final token = await SecureLocalStorage.read(PrefsKeys.token);
      if (token == null || token.isEmpty) return;

      try {
        await _channel.invokeMethod<void>('ensureChannels');
      } catch (error) {
        debugPrint('ensureChannels failed: $error');
      }

      await _ensureAndroidPermissions();
      await _syncPendingNativeToken();
    });
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

  static Future<void> _ensureIosPermissions() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
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
}
