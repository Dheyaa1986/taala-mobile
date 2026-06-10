class TicketMessageModel {
  final String id;
  final String body;
  final bool isFromAdmin;
  final String senderName;
  final DateTime? createdAt;

  const TicketMessageModel({
    required this.id,
    required this.body,
    required this.isFromAdmin,
    required this.senderName,
    this.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isFromAdmin: json['isFromAdmin'] == true,
      senderName: json['senderName']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class SupportTicketModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;
  final List<TicketMessageModel> messages;

  const SupportTicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.adminNote,
    this.createdAt,
    this.messages = const [],
  });

  bool get isClosed => status == 'resolved' || status == 'closed';

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      adminNote: json['adminNote']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      messages: rawMessages
          .map((e) => TicketMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SupportTicketsPageModel {
  final List<SupportTicketModel> items;
  final int totalPages;

  SupportTicketsPageModel({required this.items, required this.totalPages});

  factory SupportTicketsPageModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? json;
    final data = response['data'] as List<dynamic>? ?? [];
    return SupportTicketsPageModel(
      items: data
          .map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: response['totalPages'] as int? ?? 1,
    );
  }
}
