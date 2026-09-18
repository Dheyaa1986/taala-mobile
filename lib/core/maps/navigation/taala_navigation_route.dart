import 'package:latlong2/latlong.dart';

class TaalaNavigationStep {
  const TaalaNavigationStep({
    required this.instruction,
    required this.maneuverLocation,
    required this.distanceMeters,
    required this.durationSeconds,
    this.streetName,
  });

  final String instruction;
  final LatLng maneuverLocation;
  final double distanceMeters;
  final double durationSeconds;
  final String? streetName;
}

class TaalaNavigationRoute {
  const TaalaNavigationRoute({
    required this.points,
    required this.steps,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });

  final List<LatLng> points;
  final List<TaalaNavigationStep> steps;
  final double totalDistanceMeters;
  final double totalDurationSeconds;

  bool get isValid => points.length >= 2 && steps.isNotEmpty;
}
