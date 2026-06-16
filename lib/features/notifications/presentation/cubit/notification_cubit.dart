import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  int _countUnread(List<NotificationModel> items) =>
      items.where((item) => !item.isRead).length;

  List<NotificationModel> _filterInbox(List<NotificationModel> items) {
    return items.where((item) => !item.isOrderNotification).toList();
  }

  Future<void> loadUnreadCount() async {
    final result = await _repository.getMyNotifications(limit: 50);
    result.fold((_) {}, (page) {
      final items = _filterInbox(page.items);
      final unread = _countUnread(items);
      final current = state;
      if (current is NotificationLoaded) {
        emit(NotificationLoaded(
          items: current.items.isNotEmpty ? current.items : items,
          unreadCount: unread,
        ));
      } else {
        emit(NotificationLoaded(items: items, unreadCount: unread));
      }
    });
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
    notificationsResult.fold(
      (error) => emit(NotificationError(error.message)),
      (page) {
        final items = _filterInbox(page.items);
        emit(NotificationLoaded(
          items: items,
          unreadCount: _countUnread(items),
        ));
      },
    );
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
    result.fold(
      (_) {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) {},
    );
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updatedItems =
        current.items.map((item) => item.copyWith(isRead: true)).toList();

    emit(NotificationLoaded(items: updatedItems, unreadCount: 0));

    final result = await _repository.markAllAsRead();
    result.fold(
      (_) {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) {},
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
      (_) {
        emit(NotificationLoaded(
          items: current.items,
          unreadCount: current.unreadCount,
        ));
      },
      (_) {},
    );
  }
}
