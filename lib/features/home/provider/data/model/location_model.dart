import 'package:taal/features/home/provider/data/model/governate.dart';

class LocationModel {
  String? id;
  String? cityId;
  GovernanceModel? governance;
  CityModel? city;
  RegionModel? region;
  String? lng;
  String? lat;
  String? mapLink;
  String? countryName;
  String? governorateName;
  String? cityName;

  LocationModel({
    this.id,
    this.cityId,
    this.governance,
    this.region,
    this.city,
    this.lat,
    this.lng,
    this.mapLink,
    this.countryName,
    this.governorateName,
    this.cityName,
  });

  String? get googleMapsUrl => mapLink;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final governorateName = json['governorateName']?.toString();
    final cityName = json['cityName']?.toString();
    final countryName = json['countryName']?.toString();
    final cityJson = json['city'] as Map<String, dynamic>?;

    return LocationModel(
      id: json['id']?.toString(),
      cityId: cityJson?['id']?.toString() ?? json['cityId']?.toString(),
      mapLink: json['googleMapsUrl']?.toString() ?? json['mapLink']?.toString(),
      countryName: countryName,
      governorateName: governorateName,
      cityName: cityName,
      governance: governorateName != null
          ? GovernanceModel(name: governorateName, id: null)
          : null,
      city: cityName != null ? CityModel(name: cityName, id: cityJson?['id']?.toString()) : null,
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
    );
  }
}
