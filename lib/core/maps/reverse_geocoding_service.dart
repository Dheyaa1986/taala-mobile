import 'package:dio/dio.dart';

class ReverseGeocodingService {
  ReverseGeocodingService() : _dio = Dio();

  final Dio _dio;

  Future<String?> resolveAddress(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'accept-language': 'ar',
        },
        options: Options(
          headers: {'User-Agent': 'TaalaMobile/1.0 (com.mintops.taala)'},
        ),
      );
      final data = response.data;
      return data?['display_name']?.toString();
    } catch (_) {
      return null;
    }
  }
}
