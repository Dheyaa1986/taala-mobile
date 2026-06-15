import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:taal/core/alerts/app_alert_sound_service.dart';
import 'package:taal/core/alerts/push_notification_service.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/support/data/repository/support_ticket_repository.dart';

class AppAlertMonitor {
  AppAlertMonitor(
    this._soundService,
    this._notificationRepository,
    this._orderRepository,
    this._supportRepository,
    this._profileRepository,
  );

  final AppAlertSoundService _soundService;
  final NotificationRepository _notificationRepository;
  final ServiceOrderRepository _orderRepository;
  final SupportTicketRepository _supportRepository;
  final ProfileRepository _profileRepository;

  static const _pollInterval = Duration(seconds: 4);

  Timer? _timer;
  bool _initialized = false;
  bool _isTicking = false;
  String? _myUserId;

  final Set<String> _knownNotificationIds = {};
  final Set<String> _knownOrderIds = {};
  final Map<String, int> _knownMessageCounts = {};
  final Map<String, int> _knownSupportMessageCounts = {};

  final ValueNotifier<int> ordersRefreshTick = ValueNotifier<int>(0);

  bool get _isProvider =>
      getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;

  void start() {
    _timer?.cancel();
    _initialized = false;
    _knownNotificationIds.clear();
    _knownOrderIds.clear();
    _knownMessageCounts.clear();
    _knownSupportMessageCounts.clear();
    _timer = Timer.periodic(_pollInterval, (_) => _tick());
    _tick();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _initialized = false;
  }

  Future<void> _resolveMyUserId() async {
    if (_myUserId != null) return;
    final profile = await _profileRepository.getMyProfile();
    profile.fold((_) {}, (user) => _myUserId = user.id);
  }

  Future<void> _tick() async {
    if (_isTicking) return;
    _isTicking = true;

    try {
      await _resolveMyUserId();

      var shouldAlert = false;
      shouldAlert = await _checkNotifications() || shouldAlert;
      shouldAlert = await _checkOrders() || shouldAlert;
      shouldAlert = await _checkSupportTickets() || shouldAlert;

      await getIt<NotificationCubit>().loadUnreadCount();
      ordersRefreshTick.value++;

      if (_initialized && shouldAlert) {
        await _soundService.play();
        await PushNotificationService.instance.showUrgentAlert(
          title: 'تنبيه طلاء',
          body: 'لديك إشعار أو طلب جديد',
        );
      }

      _initialized = true;
    } finally {
      _isTicking = false;
    }
  }

  Future<bool> _checkNotifications() async {
    var changed = false;
    final result = await _notificationRepository.getMyNotifications(limit: 30);
    result.fold((_) {}, (page) {
      for (final item in page.items) {
        if (_isProvider && item.linkedServiceOrderId != null) {
          _knownNotificationIds.add(item.id);
          continue;
        }

        final isNew = !_knownNotificationIds.contains(item.id);
        if (isNew) {
          if (_initialized && !item.isRead) {
            changed = true;
          }
          _knownNotificationIds.add(item.id);
        }
      }
    });
    return changed;
  }

  Future<bool> _checkOrders() async {
    var changed = false;
    final listResult = await _orderRepository.getMyOrders(limit: 30);
    await listResult.fold((_) async {}, (orders) async {
      var activeChecks = 0;
      for (final order in orders) {
        final id = order.id;
        if (id == null) continue;

        final isNewOrder = !_knownOrderIds.contains(id);
        if (isNewOrder) {
          if (_initialized && _isProvider && order.status == 'pending') {
            changed = true;
          }
          _knownOrderIds.add(id);
        }

        if (order.status == 'completed' ||
            order.status == 'cancelled' ||
            activeChecks >= 5) {
          continue;
        }
        activeChecks++;

        final detailResult = await _orderRepository.getOrder(id);
        detailResult.fold((_) {}, (detail) {
          final count = detail.messages.length;
          final previousCount = _knownMessageCounts[id] ?? 0;
          if (count > previousCount && _initialized) {
            final incoming = detail.messages
                .skip(previousCount)
                .any((message) => message.senderId != _myUserId);
            if (incoming) changed = true;
          }
          _knownMessageCounts[id] = count;
        });
      }
    });
    return changed;
  }

  Future<bool> _checkSupportTickets() async {
    var changed = false;
    final listResult = await _supportRepository.getMyTickets(limit: 20);
    await listResult.fold((_) async {}, (page) async {
      for (final ticket in page.items) {
        if (ticket.isClosed) continue;

        final detailResult = await _supportRepository.getTicketById(ticket.id);
        detailResult.fold((_) {}, (detail) {
          final adminCount =
              detail.messages.where((message) => message.isFromAdmin).length;
          final previousCount = _knownSupportMessageCounts[ticket.id] ?? 0;
          if (adminCount > previousCount && _initialized) {
            changed = true;
          }
          _knownSupportMessageCounts[ticket.id] = adminCount;
        });
      }
    });
    return changed;
  }
}
