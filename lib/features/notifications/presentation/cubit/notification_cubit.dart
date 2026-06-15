import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  int _countUnread(List<NotificationModel> items) =>
      items.where((item) => !item.isRead).length;

  bool get _isProvider =>
      getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;

  List<NotificationModel> _filterForRole(List<NotificationModel> items) {
    if (!_isProvider) return items;
    return items
        .where((item) => item.linkedServiceOrderId == null)
        .toList();
  }

  Future<void> loadNotifications() async {
    final previous =
        state is NotificationLoaded ? state as NotificationLoaded : null;
    if (previous != null) {
      emit(NotificationLoaded(
        items: previous.items,
        unreadCount: previous.unreadCount,
        isRefreshing: true,
      ));
    } else {
      emit(NotificationLoading());
    }

    final notificationsResult = await _repository.getMyNotifications();
    final countResult = await _repository.getUnreadCount();

    notificationsResult.fold(
      (error) => emit(NotificationError(error.message)),
      (page) {
        final items = _filterForRole(page.items);
        final unreadFromItems = _countUnread(items);
        final unread =
            countResult.fold((_) => unreadFromItems, (count) {
          if (_isProvider) return unreadFromItems;
          return count;
        });
        emit(NotificationLoaded(
          items: items,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> loadUnreadCount() async {
    if (_isProvider) {
      await loadNotifications();
      return;
    }

    final countResult = await _repository.getUnreadCount();
    countResult.fold((_) {}, (count) {
      final current = state;
      if (current is NotificationLoaded) {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: count,
        ));
      } else {
        emit(NotificationLoaded(items: const [], unreadCount: count));
      }
    });
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updatedItems = current.items
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();

    emit(NotificationLoaded(
      items: updatedItems,
      unreadCount: _countUnread(updatedItems),
    ));

    final result = await _repository.markAsRead(id);
    await result.fold(
      (_) async {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) async {
        final countResult = await _repository.getUnreadCount();
        countResult.fold(
          (_) {},
          (count) => emit(NotificationLoaded(
            items: updatedItems,
            unreadCount: count,
          )),
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updatedItems =
        current.items.map((item) => item.copyWith(isRead: true)).toList();

    emit(NotificationLoaded(items: updatedItems, unreadCount: 0));

    final result = await _repository.markAllAsRead();
    await result.fold(
      (_) async {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) async => loadUnreadCount(),
    );
  }

  Future<void> deleteNotification(String id) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updatedItems =
        current.items.where((item) => item.id != id).toList();

    emit(NotificationLoaded(
      items: updatedItems,
      unreadCount: _countUnread(updatedItems),
    ));

    final result = await _repository.deleteNotification(id);
    result.fold(
      (_) async {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) async => loadUnreadCount(),
    );
  }
}
