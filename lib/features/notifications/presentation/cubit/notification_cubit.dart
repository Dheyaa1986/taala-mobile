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
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
  }
}
