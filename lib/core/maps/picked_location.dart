import 'package:equatable/equatable.dart';

import 'maps_helper.dart';

class PickedLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String get googleMapsUrl => MapsHelper.googleMapsUrl(latitude, longitude);

  String get lat => latitude.toStringAsFixed(6);

  String get lng => longitude.toStringAsFixed(6);

  factory PickedLocation.fromGoogleMapsUrl(String url, {String? address}) {
    final coords = MapsHelper.parseFromGoogleUrl(url);
    if (coords == null) {
      throw ArgumentError('Invalid Google Maps URL');
    }
    return PickedLocation(
      latitude: coords.latitude,
      longitude: coords.longitude,
      address: address,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address];
}
