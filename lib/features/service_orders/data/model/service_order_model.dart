import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';

class ServiceOrderMessageModel {
  final String? id;
  final String? message;
  final String? senderId;
  final String? senderName;
  final DateTime? createdAt;

  const ServiceOrderMessageModel({
    this.id,
    this.message,
    this.senderId,
    this.senderName,
    this.createdAt,
  });

  factory ServiceOrderMessageModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderMessageModel(
      id: json['id']?.toString(),
      message: json['message']?.toString(),
      senderId: json['sender']?['id']?.toString(),
      senderName: json['sender']?['name']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class ServiceOrderModel {
  final String? id;
  final String? description;
  final String? status;
  final String? clientAddress;
  final double? clientLatitude;
  final double? clientLongitude;
  final String? destinationAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double? agreedPrice;
  final DateTime? priceLockedAt;
  final DateTime? clientReadyAt;
  final DateTime? providerEnRouteAt;
  final String? cancellationReason;
  final double? distanceKm;
  final int? etaMinutes;
  final String? providerName;
  final String? clientName;
  final ServiceTypeModel? serviceType;
  final List<ServiceOrderMessageModel> messages;

  const ServiceOrderModel({
    this.id,
    this.description,
    this.status,
    this.clientAddress,
    this.clientLatitude,
    this.clientLongitude,
    this.destinationAddress,
    this.destinationLatitude,
    this.destinationLongitude,
    this.agreedPrice,
    this.priceLockedAt,
    this.clientReadyAt,
    this.providerEnRouteAt,
    this.cancellationReason,
    this.distanceKm,
    this.etaMinutes,
    this.providerName,
    this.clientName,
    this.serviceType,
    this.messages = const [],
  });

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return ServiceOrderModel(
      id: json['id']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      clientAddress: json['clientAddress']?.toString(),
      clientLatitude: ApiResponseHelper.parseDouble(json['clientLatitude']),
      clientLongitude: ApiResponseHelper.parseDouble(json['clientLongitude']),
      destinationAddress: json['destinationAddress']?.toString(),
      destinationLatitude:
          ApiResponseHelper.parseDouble(json['destinationLatitude']),
      destinationLongitude:
          ApiResponseHelper.parseDouble(json['destinationLongitude']),
      agreedPrice: ApiResponseHelper.parseDouble(json['agreedPrice']),
      priceLockedAt: json['priceLockedAt'] != null
          ? DateTime.tryParse(json['priceLockedAt'].toString())
          : null,
      clientReadyAt: json['clientReadyAt'] != null
          ? DateTime.tryParse(json['clientReadyAt'].toString())
          : null,
      providerEnRouteAt: json['providerEnRouteAt'] != null
          ? DateTime.tryParse(json['providerEnRouteAt'].toString())
          : null,
      cancellationReason: json['cancellationReason']?.toString(),
      distanceKm: ApiResponseHelper.parseDouble(json['distanceKm']),
      etaMinutes: ApiResponseHelper.parseInt(json['etaMinutes']),
      providerName: json['provider']?['name']?.toString(),
      clientName: json['client']?['name']?.toString(),
      serviceType: json['serviceType'] != null
          ? ServiceTypeModel.fromJson(
              json['serviceType'] as Map<String, dynamic>,
            )
          : null,
      messages: rawMessages
          .whereType<Map>()
          .map(
            (item) => ServiceOrderMessageModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class ServiceOrderTrackingModel {
  final String? orderId;
  final String? status;
  final double? providerLatitude;
  final double? providerLongitude;
  final double? distanceKm;
  final int? etaMinutes;

  const ServiceOrderTrackingModel({
    this.orderId,
    this.status,
    this.providerLatitude,
    this.providerLongitude,
    this.distanceKm,
    this.etaMinutes,
  });

  factory ServiceOrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderTrackingModel(
      orderId: json['orderId']?.toString(),
      status: json['status']?.toString(),
      providerLatitude: ApiResponseHelper.parseDouble(json['providerLatitude']),
      providerLongitude: ApiResponseHelper.parseDouble(json['providerLongitude']),
      distanceKm: ApiResponseHelper.parseDouble(json['distanceKm']),
      etaMinutes: ApiResponseHelper.parseInt(json['etaMinutes']),
    );
  }
}
