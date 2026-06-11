import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String? supportTicketId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.supportTicketId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? supportTicketId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      supportTicketId: supportTicketId ?? this.supportTicketId,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true ||
          json['isRead'] == 1 ||
          json['isRead'] == 'true',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      supportTicketId: json['supportTicketId']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [id, title, message, isRead, createdAt, supportTicketId];
}

class NotificationsPageModel {
  NotificationsPageModel({
    required this.items,
    required this.totalPages,
    required this.currentPage,
  });

  final List<NotificationModel> items;
  final int totalPages;
  final int currentPage;

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? json;
    final data = response['data'] as List<dynamic>? ?? [];
    return NotificationsPageModel(
      items: data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: response['totalPages'] as int? ?? 1,
      currentPage: response['currentPage'] as int? ?? 1,
    );
  }
}
