import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taal/firebase_options.dart';

import 'push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.instance.ensureLocalNotificationsReady();
  await PushNotificationService.instance.showUrgentAlert(
    title: message.notification?.title ??
        message.data['title'] ??
        'تنبيه طلاء',
    body: message.notification?.body ??
        message.data['body'] ??
        'لديك إشعار جديد',
  );
}
