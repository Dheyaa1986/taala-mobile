import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taal/firebase_options.dart';
import 'package:taal/core/alerts/app_alert_sound_service.dart';
import 'package:taal/core/alerts/app_icon_badge_service.dart';
import 'package:taal/core/alerts/notification_router.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/secure_local_storage.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _localReady = false;
  bool _firebaseReady = false;
  bool _launchHandled = false;

  Future<bool> initialize() async {
    await ensureLocalNotificationsReady();
    if (_firebaseReady) return true;
    _firebaseReady = await _setupFirebaseMessaging();
    return _firebaseReady;
  }

  Future<void> ensureLocalNotificationsReady() async {
    if (_localReady) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        NotificationRouter.handlePayloadString(response.payload);
      },
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'taala_urgent_orders',
        'طلبات ورسائل عاجلة',
        description: 'تنبيهات الطلبات والرسائل',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    _localReady = true;
  }

  Future<bool> _setupFirebaseMessaging() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM permission denied');
        return false;
      }

      FirebaseMessaging.onMessage.listen(handleIncomingMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        await NotificationRouter.handleRemoteMessage(message);
      });

      await _registerCurrentToken(messaging);
      messaging.onTokenRefresh.listen(_registerTokenWithBackend);
      return true;
    } catch (error) {
      debugPrint('Firebase messaging setup failed: $error');
      return false;
    }
  }

  Future<void> processLaunchNotifications() async {
    if (_launchHandled) return;
    _launchHandled = true;

    if (!_firebaseReady) {
      await initialize();
    }

    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        await NotificationRouter.handleRemoteMessage(initial);
        return;
      }
    } catch (error) {
      debugPrint('getInitialMessage failed: $error');
    }

    if (Platform.isAndroid) {
      await NotificationRouter.consumeAndroidLaunchPayload();
    }

    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        await NotificationRouter.handlePayloadString(
          launchDetails?.notificationResponse?.payload,
        );
      }
    } catch (error) {
      debugPrint('Local launch notification failed: $error');
    }
  }

  Future<void> _registerCurrentToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('FCM token is empty');
      return;
    }
    await _registerTokenWithBackend(token);
  }

  Future<void> syncTokenIfLoggedIn() async {
    if (!_firebaseReady) {
      await initialize();
    }
    if (!_firebaseReady) return;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await _registerTokenWithBackend(token);
          return;
        }
      } catch (error) {
        debugPrint('FCM token sync attempt ${attempt + 1} failed: $error');
      }
      await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
  }

  Future<void> registerToken(String token) async {
    await _registerTokenWithBackend(token);
  }

  Future<void> clearTokenFromBackend() async {
    final accessToken = await SecureLocalStorage.read(PrefsKeys.token);
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await getIt<DioService>().callApi(
        NetworkRequest(
          AppUrls.notificationsFcmToken,
          method: RequestMethod.delete,
        ),
      );
    } catch (error) {
      debugPrint('FCM token clear failed: $error');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    final accessToken = await SecureLocalStorage.read(PrefsKeys.token);
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('Skip FCM register: user not logged in');
      return;
    }

    try {
      await getIt<DioService>().callApi(
        NetworkRequest(
          AppUrls.notificationsFcmToken,
          method: RequestMethod.post,
          body: {'token': token},
        ),
      );
      debugPrint('FCM token registered with backend');
    } catch (error) {
      debugPrint('FCM token registration failed: $error');
    }
  }

  Future<void> handleIncomingMessage(
    RemoteMessage message, {
    bool background = false,
  }) async {
    final data = NotificationRouter.fromRemoteMessage(message);
    final type = data['type']?.trim();
    if (type == 'badge_sync') {
      final badge = int.tryParse(data['badge'] ?? '');
      if (badge != null) {
        await AppIconBadgeService.applyCount(badge);
      }
      return;
    }

    final title = message.notification?.title ??
        data['title'] ??
        'تنبيه طلاء';
    final body = message.notification?.body ??
        data['body'] ??
        'لديك إشعار جديد';
    final badge = int.tryParse(data['badge'] ?? '');

    if (badge != null) {
      await AppIconBadgeService.applyCount(badge);
    }

    if (background) {
      if (Platform.isAndroid) {
        return;
      }
      await showUrgentAlert(
        title: title,
        body: body,
        badgeNumber: badge,
        payload: data,
      );
      return;
    }

    await showUrgentAlert(
      title: title,
      body: body,
      badgeNumber: badge,
      payload: data,
    );
    await getIt<AppAlertSoundService>().play(force: true);

    try {
      await getIt<NotificationCubit>().refreshInbox(reloadList: true);
    } catch (error) {
      debugPrint('Notification refresh failed: $error');
    }
  }

  Future<void> showUrgentAlert({
    required String title,
    required String body,
    int? badgeNumber,
    Map<String, String>? payload,
  }) async {
    await ensureLocalNotificationsReady();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'taala_urgent_orders',
        'طلبات ورسائل عاجلة',
        channelDescription: 'تنبيهات الطلبات والرسائل',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: badgeNumber,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload == null ? null : jsonEncode(payload),
    );
  }
}
