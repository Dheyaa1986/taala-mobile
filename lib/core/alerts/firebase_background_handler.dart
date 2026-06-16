import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taal/firebase_options.dart';

import 'push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isAndroid) {
    await PushNotificationService.instance.handleIncomingMessage(
      message,
      background: true,
    );
    return;
  }

  await PushNotificationService.instance.ensureLocalNotificationsReady();
  await PushNotificationService.instance.handleIncomingMessage(
    message,
    background: true,
  );
}
