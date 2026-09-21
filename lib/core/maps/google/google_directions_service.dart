import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/google/google_maps_config.dart';
import 'package:taal/core/maps/navigation/maneuver_instructions.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';

class GoogleDirectionsService {
  GoogleDirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  Future<TaalaNavigationRoute?> fetchNavigationRoute(
    LatLng from,
    LatLng to,
  ) async {
    final key = GoogleMapsConfig.apiKey;
    if (key == null || key.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'origin': '${from.latitude},${from.longitude}',
          'destination': '${to.latitude},${to.longitude}',
          'mode': 'driving',
          'language': 'ar',
          'key': key,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final overview = route['overview_polyline'] as Map<String, dynamic>?;
      final encoded = overview?['points'] as String?;
      if (encoded == null || encoded.isEmpty) return null;

      final points = _decodePolyline(encoded);
      if (points.length < 2) return null;

      final legs = route['legs'] as List<dynamic>? ?? const [];
      final steps = <TaalaNavigationStep>[];
      var totalDistance = 0.0;
      var totalDuration = 0.0;

      for (final leg in legs) {
        final legMap = leg as Map<String, dynamic>;
        totalDistance += (legMap['distance']?['value'] as num?)?.toDouble() ?? 0;
        totalDuration += (legMap['duration']?['value'] as num?)?.toDouble() ?? 0;

        final legSteps = legMap['steps'] as List<dynamic>? ?? const [];
        for (final step in legSteps) {
          final stepMap = step as Map<String, dynamic>;
          final start = stepMap['start_location'] as Map<String, dynamic>?;
          if (start == null) continue;

          final html = stepMap['html_instructions'] as String? ?? '';
          final instruction = _stripHtml(html);
          final maneuver = stepMap['maneuver'] as String?;
          final streetName = stepMap['name'] as String?;

          steps.add(
            TaalaNavigationStep(
              instruction: instruction.isNotEmpty
                  ? instruction
                  : buildManeuverInstruction(
                      apiInstruction: null,
                      type: maneuver,
                      modifier: null,
                      streetName: streetName,
                    ),
              maneuverLocation: LatLng(
                (start['lat'] as num).toDouble(),
                (start['lng'] as num).toDouble(),
              ),
              distanceMeters:
                  (stepMap['distance']?['value'] as num?)?.toDouble() ?? 0,
              durationSeconds:
                  (stepMap['duration']?['value'] as num?)?.toDouble() ?? 0,
              streetName: streetName,
            ),
          );
        }
      }

      return TaalaNavigationRoute(
        points: points,
        steps: steps,
        totalDistanceMeters: totalDistance,
        totalDurationSeconds: totalDuration,
      );
    } catch (_) {
      return null;
    }
  }

  static String _stripHtml(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
