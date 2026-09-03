import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/alerts/app_icon_badge_service.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/secure_local_storage.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

class NotificationRouter {
  NotificationRouter._();

  static const _androidChannel = MethodChannel('com.mintops.taala/alerts');
  static Map<String, String>? _pendingPayload;

  static Map<String, String> fromRemoteMessage(RemoteMessage message) {
    return message.data.map((key, value) => MapEntry(key, value.toString()));
  }

  static Map<String, String>? fromPayloadString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );
      }
    } catch (_) {
      debugPrint('Invalid notification payload: $raw');
    }
    return null;
  }

  static Future<void> handleRemoteMessage(RemoteMessage message) async {
    await handlePayload(fromRemoteMessage(message));
  }

  static Future<void> handlePayloadString(String? raw) async {
    if (raw == null || raw.trim().isEmpty) return;
    final payload = fromPayloadString(raw);
    if (payload != null) {
      await handlePayload(payload);
    }
  }

  static Future<void> handlePayload(Map<String, String> data) async {
    final type = data['type']?.trim();
    if (type == 'badge_sync') {
      final badge = int.tryParse(data['badge'] ?? '');
      if (badge != null) {
        await AppIconBadgeService.applyCount(badge);
      }
      return;
    }

    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) {
      _pendingPayload = Map<String, String>.from(data);
      return;
    }

    await _applySideEffects(data);
    await _navigate(data);
  }

  static Future<void> processPendingIfAny() async {
    final pending = _pendingPayload;
    if (pending == null) return;
    _pendingPayload = null;

    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (token == null || token.isEmpty) {
      _pendingPayload = pending;
      return;
    }

    await _applySideEffects(pending);
    await _navigate(pending);
  }

  static Future<void> consumeAndroidLaunchPayload() async {
    try {
      final raw = await _androidChannel.invokeMethod<Object?>(
        'consumeLaunchNotificationPayload',
      );
      if (raw is Map) {
        final payload = raw.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );
        if (payload.isNotEmpty) {
          await handlePayload(payload);
        }
      }
    } catch (error) {
      debugPrint('Android launch payload failed: $error');
    }
  }

  static Future<void> _applySideEffects(Map<String, String> data) async {
    final badge = int.tryParse(data['badge'] ?? '');
    if (badge != null) {
      await AppIconBadgeService.applyCount(badge);
    }

    final notificationId = data['notificationId']?.trim();
    if (notificationId != null && notificationId.isNotEmpty) {
      try {
        await getIt<NotificationCubit>().markAsReadFromPush(notificationId);
      } catch (error) {
        debugPrint('Mark-as-read from push failed: $error');
      }
      return;
    }

    try {
      await getIt<NotificationCubit>().refreshInbox(reloadList: true);
    } catch (error) {
      debugPrint('Inbox refresh from push failed: $error');
    }
  }

  static Future<void> _navigate(Map<String, String> data) async {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _pendingPayload = Map<String, String>.from(data);
      return;
    }

    final orderId = data['serviceOrderId']?.trim();
    if (orderId != null && orderId.isNotEmpty) {
      await ServiceOrderLocalStateHelper.undismiss(orderId);
      await ServiceOrderLocalStateHelper.markRead(orderId);
      ServiceOrderNavigation.openDetail(orderId, openChat: true);
      return;
    }

    final ticketId = data['supportTicketId']?.trim();
    if (ticketId != null && ticketId.isNotEmpty) {
      context.pushNamed(
        Routes.supportTicketDetail,
        pathParameters: {'id': ticketId},
      );
      return;
    }

    final target = data['target']?.trim();
    if (target == 'inbox' || data['type'] == 'inbox') {
      context.pushNamed(Routes.notifications);
    }
  }
}
