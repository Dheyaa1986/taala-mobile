import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/google/google_directions_service.dart';
import 'package:taal/core/maps/google/google_maps_config.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';

/// Routes via Google Directions when configured, otherwise OSRM.
class TaalaRoutingService {
  TaalaRoutingService({
    required OsrmRoutingService osrm,
    required GoogleDirectionsService google,
  })  : _osrm = osrm,
        _google = google;

  final OsrmRoutingService _osrm;
  final GoogleDirectionsService _google;

  Future<List<LatLng>> fetchDrivingRoute(LatLng from, LatLng to) async {
    final route = await fetchNavigationRoute(from, to);
    if (route != null && route.points.isNotEmpty) return route.points;
    return _osrm.fetchDrivingRoute(from, to);
  }

  Future<TaalaNavigationRoute?> fetchNavigationRoute(
    LatLng from,
    LatLng to,
  ) async {
    if (GoogleMapsConfig.isEnabled) {
      final googleRoute = await _google.fetchNavigationRoute(from, to);
      if (googleRoute != null && googleRoute.isValid) {
        return googleRoute;
      }
    }
    return _osrm.fetchNavigationRoute(from, to);
  }
}
