import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String? supportTicketId;
  final String? serviceOrderId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.supportTicketId,
    this.serviceOrderId,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? supportTicketId,
    String? serviceOrderId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      supportTicketId: supportTicketId ?? this.supportTicketId,
      serviceOrderId: serviceOrderId ?? this.serviceOrderId,
    );
  }

  bool get isOrderNotification {
    if (serviceOrderId != null && serviceOrderId!.isNotEmpty) {
      return true;
    }
    return title.contains('طلب خدمة') ||
        title.contains('رسالة جديدة في طلب الخدمة') ||
        title.contains('تحديث حالة الطلب') ||
        title.contains('عرض سعر من المزود');
  }

  String? get linkedServiceOrderId {
    if (serviceOrderId != null && serviceOrderId!.isNotEmpty) {
      return serviceOrderId;
    }
    if (_isServiceOrderNotification && supportTicketId != null) {
      return supportTicketId;
    }
    return null;
  }

  bool get _isServiceOrderNotification {
    return title.contains('طلب خدمة') ||
        title.contains('رسالة جديدة في طلب الخدمة') ||
        title.contains('تحديث حالة الطلب');
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
      serviceOrderId: json['serviceOrderId']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [id, title, message, isRead, createdAt, supportTicketId, serviceOrderId];
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
