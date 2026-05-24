import 'package:location/location.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';

class ServiceProviderModel {
  int? id;
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
  ServiceProviderModel(
      {this.id,
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
      this.lng});

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      rate: json['rate'],
      totalRatings: json['totalRatings'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : [],
      locations: json['locations'] != null
          ? List<LocationModel>.from(
              json['locations'].map((x) => LocationModel.fromJson(x)))
          : [],
      phone: json['phone'],
      image: json['image'],
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
