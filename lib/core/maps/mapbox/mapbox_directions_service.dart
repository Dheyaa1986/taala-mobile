import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/mapbox/mapbox_config.dart';

class MapboxDirectionsService {
  MapboxDirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';

  Future<List<LatLng>> fetchDrivingRoute(LatLng from, LatLng to) async {
    final token = MapboxConfig.accessToken;
    if (token == null || token.isEmpty) return [from, to];

    try {
      final coordinates =
          '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
      final url =
          '$_baseUrl/$coordinates?overview=full&geometries=geojson&access_token=$token';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 12),
        ),
      );

      final routes = response.data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return [from, to];

      final geometry = routes.first['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.isEmpty) return [from, to];

      return coords
          .map((point) {
            final pair = point as List<dynamic>;
            return LatLng(
              (pair[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            );
          })
          .toList(growable: false);
    } catch (_) {
      return [from, to];
    }
  }
}
