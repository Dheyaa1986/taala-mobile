import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OsrmRoutingService {
  OsrmRoutingService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> fetchDrivingRoute(LatLng from, LatLng to) async {
    try {
      final url =
          '$_baseUrl/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
          '?overview=full&geometries=geojson';
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
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (coordinates == null || coordinates.isEmpty) return [from, to];

      return coordinates
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
