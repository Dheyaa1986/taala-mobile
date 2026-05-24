import 'package:taal/features/home/provider/data/model/governate.dart';

class LocationModel{
   String? id;
   GovernanceModel? governance;
   CityModel? city;
   RegionModel? region;
   String? lng;
   String? lat;
   String? mapLink;

  LocationModel({
     this.id,
     this.governance,
     this.region,
     this.city,
     this.lat,
     this.lng,
     this.mapLink,
  });


  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      mapLink:  json['mapLink'],
      id: json['id'],
      governance: json['governance'] != null
          ? GovernanceModel.fromJson(json['governance'])
          : null,
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'])
          : null,
      city: json['city'] != null
          ? CityModel.fromJson(json['city'])
          : null,
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}