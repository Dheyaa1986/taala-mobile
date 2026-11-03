import 'package:easy_localization/easy_localization.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';

class OfflineFallbackRoute {
  const OfflineFallbackRoute._();

  static const _distance = Distance();
  static const _urbanSpeedMps = 30 * 1000 / 3600;

  static TaalaNavigationRoute build(LatLng from, LatLng to) {
    final meters = _distance.as(LengthUnit.Meter, from, to);
    final duration = (meters / _urbanSpeedMps).clamp(30, 86400).toDouble();
    return TaalaNavigationRoute(
      points: _interpolate(from, to, meters),
      steps: [
        TaalaNavigationStep(
          instruction: AppStrings.navigationFollowDestination.tr(),
          maneuverLocation: to,
          distanceMeters: meters,
          durationSeconds: duration,
        ),
      ],
      totalDistanceMeters: meters,
      totalDurationSeconds: duration,
      isApproximate: true,
    );
  }

  static List<LatLng> _interpolate(LatLng from, LatLng to, double meters) {
    if (meters < 80) return [from, to];
    final bearing = _distance.bearing(from, to);
    final points = <LatLng>[from];
    var travelled = 120.0;
    while (travelled < meters - 40) {
      points.add(_distance.offset(from, travelled, bearing));
      travelled += 120;
    }
    points.add(to);
    return points;
  }
}
