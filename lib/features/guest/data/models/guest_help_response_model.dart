import 'package:taal/features/service_orders/data/model/service_order_model.dart';

class GuestHelpResponseModel {
  GuestHelpResponseModel({
    required this.token,
    required this.refreshToken,
    required this.isNewAccount,
    required this.order,
  });

  final String token;
  final String refreshToken;
  final bool isNewAccount;
  final ServiceOrderModel order;

  factory GuestHelpResponseModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? json;
    return GuestHelpResponseModel(
      token: response['token']?.toString() ?? '',
      refreshToken: response['refreshToken']?.toString() ?? '',
      isNewAccount: response['isNewAccount'] == true,
      order: ServiceOrderModel.fromJson(
        response['order'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
