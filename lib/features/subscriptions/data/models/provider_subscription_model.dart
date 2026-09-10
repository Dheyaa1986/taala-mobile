class ProviderSubscriptionModel {
  const ProviderSubscriptionModel({
    required this.status,
    required this.canReceiveOrders,
    this.planId,
    this.ordersRemaining,
    this.ordersUsed = 0,
    this.expiresAt,
    this.message,
    this.planName,
  });

  final String status;
  final bool canReceiveOrders;
  final String? planId;
  final int? ordersRemaining;
  final int ordersUsed;
  final DateTime? expiresAt;
  final String? message;
  final String? planName;

  bool get isTrial => status == 'trial';

  factory ProviderSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    return ProviderSubscriptionModel(
      status: json['status']?.toString() ?? 'expired',
      canReceiveOrders: json['canReceiveOrders'] == true,
      planId: plan?['id']?.toString(),
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
    this.durationUnit,
    this.durationValue,
    this.orderQuota,
    this.cardColor,
    this.cardStyle = 'border',
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String billingType;
  final double price;
  final String currency;
  final String? durationUnit;
  final int? durationValue;
  final int? orderQuota;
  final String? cardColor;
  final String cardStyle;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      billingType: json['billingType']?.toString() ?? 'time_based',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'IQD',
      durationUnit: json['durationUnit']?.toString(),
      durationValue: _parseInt(json['durationValue']),
      orderQuota: _parseInt(json['orderQuota']),
      cardColor: json['cardColor']?.toString(),
      cardStyle: json['cardStyle']?.toString() ?? 'border',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class TrialOfferModel {
  const TrialOfferModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.durationDays,
    required this.maxOrders,
    required this.cardColor,
    required this.cardStyle,
    this.price = 0,
    this.currency = 'IQD',
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final int durationDays;
  final int maxOrders;
  final String cardColor;
  final String cardStyle;
  final double price;
  final String currency;

  factory TrialOfferModel.fromJson(Map<String, dynamic> json) {
    return TrialOfferModel(
      id: json['id']?.toString() ?? 'trial',
      nameAr: json['nameAr']?.toString() ?? 'تجربة مجانية',
      nameEn: json['nameEn']?.toString() ?? 'Free trial',
      durationDays: _parseInt(json['durationDays']) ?? 14,
      maxOrders: _parseInt(json['maxOrders']) ?? 10,
      cardColor: json['cardColor']?.toString() ?? '#22C55E',
      cardStyle: json['cardStyle']?.toString() ?? 'border',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'IQD',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
