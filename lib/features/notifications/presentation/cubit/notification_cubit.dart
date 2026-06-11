import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/data/repository/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(NotificationInitial());

  final NotificationRepository _repository;

  int _countUnread(List<NotificationModel> items) =>
      items.where((item) => !item.isRead).length;

  Future<void> loadNotifications() async {
    final previous = state is NotificationLoaded ? state as NotificationLoaded : null;
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
        final unreadFromItems = _countUnread(page.items);
        final unread = countResult.fold((_) => unreadFromItems, (count) => count);
        emit(NotificationLoaded(
          items: page.items,
          unreadCount: unread,
        ));
      },
    );
  }

  Future<void> loadUnreadCount() async {
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

    final updatedItems = current.items
        .map(
          (item) => NotificationModel(
            id: item.id,
            title: item.title,
            message: item.message,
            isRead: true,
            createdAt: item.createdAt,
          ),
        )
        .toList();

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
}
