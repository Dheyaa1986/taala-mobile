import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/mapbox/mapbox_config.dart';
import 'package:taal/core/maps/navigation/maneuver_instructions.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';

class MapboxDirectionsService {
  MapboxDirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';

  Future<List<LatLng>> fetchDrivingRoute(LatLng from, LatLng to) async {
    final route = await fetchNavigationRoute(from, to);
    if (route == null || route.points.isEmpty) return [from, to];
    return route.points;
  }

  Future<TaalaNavigationRoute?> fetchNavigationRoute(
    LatLng from,
    LatLng to,
  ) async {
    final token = MapboxConfig.accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      final coordinates =
          '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
      final url =
          '$_baseUrl/$coordinates'
          '?overview=full'
          '&geometries=geojson'
          '&steps=true'
          '&language=ar'
          '&access_token=$token';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.isEmpty) return null;

      final points = coords
          .map((point) {
            final pair = point as List<dynamic>;
            return LatLng(
              (pair[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            );
          })
          .toList(growable: false);

      final legs = route['legs'] as List<dynamic>? ?? const [];
      final steps = <TaalaNavigationStep>[];
      for (final leg in legs) {
        final legMap = leg as Map<String, dynamic>;
        final legSteps = legMap['steps'] as List<dynamic>? ?? const [];
        for (final step in legSteps) {
          final stepMap = step as Map<String, dynamic>;
          final maneuver = stepMap['maneuver'] as Map<String, dynamic>?;
          if (maneuver == null) continue;

          final location = maneuver['location'] as List<dynamic>?;
          if (location == null || location.length < 2) continue;

          final streetName = stepMap['name'] as String?;
          steps.add(
            TaalaNavigationStep(
              instruction: buildManeuverInstruction(
                apiInstruction: maneuver['instruction'] as String?,
                type: maneuver['type'] as String?,
                modifier: maneuver['modifier'] as String?,
                streetName: streetName,
              ),
              maneuverLocation: LatLng(
                (location[1] as num).toDouble(),
                (location[0] as num).toDouble(),
              ),
              distanceMeters: (stepMap['distance'] as num?)?.toDouble() ?? 0,
              durationSeconds: (stepMap['duration'] as num?)?.toDouble() ?? 0,
              streetName: streetName,
            ),
          );
        }
      }

      return TaalaNavigationRoute(
        points: points,
        steps: steps,
        totalDistanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
        totalDurationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
