class SupportTicketModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;

  const SupportTicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.adminNote,
    this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
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
