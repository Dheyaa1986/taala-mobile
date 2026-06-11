part of 'notification_cubit.dart';

sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  NotificationLoaded({
    required this.items,
    required this.unreadCount,
    this.isRefreshing = false,
  });

  final List<NotificationModel> items;
  final int unreadCount;
  final bool isRefreshing;
}

final class NotificationError extends NotificationState {
  NotificationError(this.message);
  final String message;
}
