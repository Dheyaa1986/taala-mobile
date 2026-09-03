import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/alerts/app_icon_badge_service.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  List<NotificationModel> _filterInbox(List<NotificationModel> items) {
    return items.where((item) => !item.isOrderNotification).toList();
  }

  Future<int?> _fetchUnreadCount() async {
    final result = await _repository.getUnreadCount();
    return result.fold((_) => null, (count) => count);
  }

  Future<List<NotificationModel>?> _fetchInboxItems() async {
    final result = await _repository.getMyNotifications(limit: 50);
    return result.fold(
      (_) => null,
      (page) => _filterInbox(page.items),
    );
  }

  void _emitLoaded({
    required List<NotificationModel> items,
    required int unreadCount,
    bool isRefreshing = false,
  }) {
    emit(NotificationLoaded(
      items: items,
      unreadCount: unreadCount,
      isRefreshing: isRefreshing,
    ));
    getIt<AppIconBadgeService>().updateCount(unreadCount);
  }

  Future<void> refreshInbox({bool reloadList = false}) async {
    final unread = await _fetchUnreadCount();
    if (unread == null) return;

    if (reloadList) {
      final items = await _fetchInboxItems();
      if (items == null) return;
      _emitLoaded(items: items, unreadCount: unread);
      return;
    }

    final current = state;
    if (current is NotificationLoaded) {
      _emitLoaded(
        items: current.items,
        unreadCount: unread,
        isRefreshing: current.isRefreshing,
      );
    } else {
      _emitLoaded(items: const [], unreadCount: unread);
    }
  }

  Future<void> loadUnreadCount() => refreshInbox();

  Future<void> loadNotifications() async {
    final previous =
        state is NotificationLoaded ? state as NotificationLoaded : null;
    if (previous != null) {
      _emitLoaded(
        items: previous.items,
        unreadCount: previous.unreadCount,
        isRefreshing: true,
      );
    } else {
      emit(NotificationLoading());
    }

    final items = await _fetchInboxItems();
    final unread = await _fetchUnreadCount();
    if (items == null || unread == null) {
      if (previous != null) {
        _emitLoaded(
          items: previous.items,
          unreadCount: previous.unreadCount,
        );
      } else {
        emit(NotificationError('Failed to load notifications'));
      }
      return;
    }

    _emitLoaded(items: items, unreadCount: unread);
  }

  Future<void> markAsReadFromPush(String id) async {
    final result = await _repository.markAsRead(id);
    result.fold((_) {}, (_) => refreshInbox(reloadList: true));
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updatedItems = current.items
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();

    _emitLoaded(
      items: updatedItems,
      unreadCount: (current.unreadCount - 1).clamp(0, 999),
    );

    final result = await _repository.markAsRead(id);
    result.fold(
      (_) {
        _emitLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        );
      },
      (_) => refreshInbox(),
    );
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is NotificationLoaded) {
      final updatedItems =
          current.items.map((item) => item.copyWith(isRead: true)).toList();
      _emitLoaded(items: updatedItems, unreadCount: 0);
    } else {
      await getIt<AppIconBadgeService>().updateCount(0);
    }

    final previous = current is NotificationLoaded ? current : null;
    final result = await _repository.markAllAsRead();
    result.fold(
      (_) {
        if (previous != null) {
          _emitLoaded(
            items: previous.items,
            unreadCount: previous.unreadCount,
          );
        }
      },
      (_) => refreshInbox(reloadList: true),
    );
  }

  Future<void> deleteNotification(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final wasUnread =
        current.items.any((item) => item.id == id && !item.isRead);

    final updatedItems =
        current.items.where((item) => item.id != id).toList();

    _emitLoaded(
      items: updatedItems,
      unreadCount: wasUnread
          ? (current.unreadCount - 1).clamp(0, 999)
          : current.unreadCount,
    );

    final result = await _repository.deleteNotification(id);
    result.fold(
      (_) {
        _emitLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        );
      },
      (_) => refreshInbox(),
    );
  }
}
