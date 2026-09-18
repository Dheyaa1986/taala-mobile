import 'package:equatable/equatable.dart';

class DeviceLocationReading extends Equatable {
  const DeviceLocationReading({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speedMps,
  });

  final double latitude;
  final double longitude;
  final double? heading;
  final double? speedMps;

  bool get hasValidHeading =>
      heading != null && heading! >= 0 && heading! <= 360;

  @override
  List<Object?> get props => [latitude, longitude, heading, speedMps];
}
