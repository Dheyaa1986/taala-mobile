import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/mapbox/mapbox_config.dart';
import 'package:taal/core/maps/mapbox/mapbox_directions_service.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';

/// Routes via Mapbox Directions when configured, otherwise OSRM.
class TaalaRoutingService {
  TaalaRoutingService({
    required OsrmRoutingService osrm,
    required MapboxDirectionsService mapbox,
  })  : _osrm = osrm,
        _mapbox = mapbox;

  final OsrmRoutingService _osrm;
  final MapboxDirectionsService _mapbox;

  Future<List<LatLng>> fetchDrivingRoute(LatLng from, LatLng to) async {
    if (MapboxConfig.isEnabled) {
      return _mapbox.fetchDrivingRoute(from, to);
    }
    return _osrm.fetchDrivingRoute(from, to);
  }

  Future<TaalaNavigationRoute?> fetchNavigationRoute(
    LatLng from,
    LatLng to,
  ) async {
    if (MapboxConfig.isEnabled) {
      final mapboxRoute = await _mapbox.fetchNavigationRoute(from, to);
      if (mapboxRoute != null && mapboxRoute.isValid) {
        return mapboxRoute;
      }
    }
    return _osrm.fetchNavigationRoute(from, to);
  }
}
