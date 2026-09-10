class ProviderSubscriptionModel {
  const ProviderSubscriptionModel({
    required this.status,
    required this.canReceiveOrders,
    this.ordersRemaining,
    this.ordersUsed = 0,
    this.expiresAt,
    this.message,
    this.planName,
  });

  final String status;
  final bool canReceiveOrders;
  final int? ordersRemaining;
  final int ordersUsed;
  final DateTime? expiresAt;
  final String? message;
  final String? planName;

  factory ProviderSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return ProviderSubscriptionModel(
      status: json['status']?.toString() ?? 'expired',
      canReceiveOrders: json['canReceiveOrders'] == true,
      ordersRemaining: _parseInt(json['ordersRemaining']),
      ordersUsed: _parseInt(json['ordersUsed']) ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      message: json['message']?.toString(),
      planName: plan?['nameAr']?.toString() ?? plan?['nameEn']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.billingType,
    required this.price,
    required this.currency,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String billingType;
  final double price;
  final String currency;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      billingType: json['billingType']?.toString() ?? 'time_based',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'IQD',
    );
  }
}
