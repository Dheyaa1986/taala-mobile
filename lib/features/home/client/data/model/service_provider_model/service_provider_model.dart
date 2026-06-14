import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';

class ServiceProviderModel {
  String? id;
  String? name;
  double? rate;
  int? totalRatings;
  String? email;
  List<String> services;
  List<ServiceTypeModel> serviceTypes;
  String? phone;
  String? image;
  String? address;
  String? lat;
  String? lng;
  double? distanceKm;
  int? etaMinutes;
  List<LocationModel> locations;

  ServiceProviderModel({
    this.id,
    this.name,
    this.rate,
    this.totalRatings,
    this.locations = const [],
    this.email,
    this.services = const [],
    this.serviceTypes = const [],
    this.phone,
    this.image,
    this.address,
    this.lat,
    this.lng,
    this.distanceKm,
    this.etaMinutes,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    final serviceTypes = json['serviceTypes'] as List<dynamic>? ?? [];
    final parsedServiceTypes = serviceTypes
        .map(
          (item) => ServiceTypeModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    final imageUrl = json['imageUrl']?.toString() ?? json['image']?.toString();

    return ServiceProviderModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      rate: (json['averageRating'] as num?)?.toDouble() ??
          (json['rate'] as num?)?.toDouble(),
      totalRatings: json['ratersCount'] as int? ?? json['totalRatings'] as int?,
      services: parsedServiceTypes
          .map((item) => item.name ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      serviceTypes: parsedServiceTypes,
      locations: json['locations'] != null
          ? List<LocationModel>.from((json['locations'] as List)
              .map((x) => LocationModel.fromJson(x as Map<String, dynamic>)))
          : [],
      phone: json['phone']?.toString(),
      image: imageUrl != null && imageUrl.isNotEmpty
          ? (imageUrl.startsWith('http') ? imageUrl : AppUrls.imageLink(imageUrl))
          : null,
      address: json['address']?.toString(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
    );
  }
}
