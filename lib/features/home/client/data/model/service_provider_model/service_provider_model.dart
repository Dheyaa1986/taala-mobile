import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';

class ServiceProviderModel {
  String? id;
  String? name;
  double? rate;
  int? totalRatings;
  String? email;
  List<String> services;
  String? phone;
  String? image;
  String? address;
  String? lat;
  String? lng;
  List<LocationModel> locations;

  ServiceProviderModel({
    this.id,
    this.name,
    this.rate,
    this.totalRatings,
    this.locations = const [],
    this.email,
    this.services = const [],
    this.phone,
    this.image,
    this.address,
    this.lat,
    this.lng,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    final serviceTypes = json['serviceTypes'] as List<dynamic>? ?? [];
    final imageUrl = json['imageUrl']?.toString() ?? json['image']?.toString();

    return ServiceProviderModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      rate: (json['averageRating'] as num?)?.toDouble() ??
          (json['rate'] as num?)?.toDouble(),
      totalRatings: json['ratersCount'] as int? ?? json['totalRatings'] as int?,
      services: serviceTypes
          .map((e) =>
              (e as Map<String, dynamic>)['name']?.toString() ??
              e['nameEn']?.toString() ??
              '')
          .where((e) => e.isNotEmpty)
          .toList(),
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
    );
  }
}
