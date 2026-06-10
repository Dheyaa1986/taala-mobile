import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    final notificationsResult = await _repository.getMyNotifications();
    final countResult = await _repository.getUnreadCount();

    notificationsResult.fold(
      (error) => emit(NotificationError(error.message)),
      (page) {
        final unread = countResult.fold((_) => 0, (count) => count);
        emit(NotificationLoaded(items: page.items, unreadCount: unread));
      },
    );
  }

  Future<void> loadUnreadCount() async {
    final countResult = await _repository.getUnreadCount();
    countResult.fold((_) {}, (count) {
      final current = state;
      if (current is NotificationLoaded) {
        emit(NotificationLoaded(items: current.items, unreadCount: count));
      } else {
        emit(NotificationLoaded(items: const [], unreadCount: count));
      }
    });
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is NotificationLoaded) {
      final updatedItems = current.items
          .map(
            (item) => item.id == id
                ? NotificationModel(
                    id: item.id,
                    title: item.title,
                    message: item.message,
                    isRead: true,
                    createdAt: item.createdAt,
                  )
                : item,
          )
          .toList();
      final wasUnread =
          current.items.any((item) => item.id == id && !item.isRead);
      final newCount = wasUnread
          ? (current.unreadCount - 1).clamp(0, 999)
          : current.unreadCount;
      emit(NotificationLoaded(items: updatedItems, unreadCount: newCount));
    }

    await _repository.markAsRead(id);
    await loadUnreadCount();
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(
        NotificationLoaded(
          items: current.items
              .map(
                (item) => NotificationModel(
                  id: item.id,
                  title: item.title,
                  message: item.message,
                  isRead: true,
                  createdAt: item.createdAt,
                ),
              )
              .toList(),
          unreadCount: 0,
        ),
      );
    }

    await _repository.markAllAsRead();
    await loadUnreadCount();
  }
}
