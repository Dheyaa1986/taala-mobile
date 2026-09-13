class ProviderSubscriptionModel {
  const ProviderSubscriptionModel({
    required this.status,
    required this.canReceiveOrders,
    this.source,
    this.planId,
    this.ordersRemaining,
    this.ordersUsed = 0,
    this.expiresAt,
    this.message,
    this.planName,
  });

  final String status;
  final bool canReceiveOrders;
  final String? source;
  final String? planId;
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
      source: json['source']?.toString(),
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

class SubscriptionCheckoutModel {
  const SubscriptionCheckoutModel({
    required this.referenceId,
    required this.paymentUrl,
    required this.amount,
    required this.currency,
    required this.planId,
    required this.status,
    this.providerPhone,
  });

  final String referenceId;
  final String paymentUrl;
  final double amount;
  final String currency;
  final String planId;
  final String status;
  final String? providerPhone;

  factory SubscriptionCheckoutModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCheckoutModel(
      referenceId: json['referenceId']?.toString() ?? '',
      paymentUrl: json['paymentUrl']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'IQD',
      planId: json['planId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      providerPhone: json['providerPhone']?.toString(),
    );
  }
}

class SubscriptionPaymentStatusModel {
  const SubscriptionPaymentStatusModel({
    required this.referenceId,
    required this.status,
    required this.paid,
    required this.subscriptionActivated,
  });

  final String referenceId;
  final String status;
  final bool paid;
  final bool subscriptionActivated;

  factory SubscriptionPaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPaymentStatusModel(
      referenceId: json['referenceId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paid: json['paid'] == true,
      subscriptionActivated: json['subscriptionActivated'] == true,
    );
  }
}

