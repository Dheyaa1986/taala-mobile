import 'package:latlong2/latlong.dart';
import 'package:taal/core/helpers/connectivity_helper.dart';
import 'package:taal/core/maps/google/google_directions_service.dart';
import 'package:taal/core/maps/google/google_maps_config.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';
import 'package:taal/core/maps/offline/offline_fallback_route.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';

/// Routes via Google Directions when online, OSRM next, then an offline
/// compass path so navigation still works without internet.
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
    return [from, to];
  }

  Future<TaalaNavigationRoute?> fetchNavigationRoute(
    LatLng from,
    LatLng to,
  ) async {
    final online = await ConnectivityHelper.connected;
    if (online) {
      if (GoogleMapsConfig.isEnabled) {
        final googleRoute = await _google.fetchNavigationRoute(from, to);
        if (googleRoute != null && googleRoute.isValid) {
          return googleRoute;
        }
      }
      final osrmRoute = await _osrm.fetchNavigationRoute(from, to);
      if (osrmRoute != null && osrmRoute.isValid) {
        return osrmRoute;
      }
    }
    return OfflineFallbackRoute.build(from, to);
  }
}
