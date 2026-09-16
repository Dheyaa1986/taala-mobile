import 'package:dio/dio.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}

class PlaceSearchService {
  PlaceSearchService() : _dio = Dio();

  final Dio _dio;

  Future<List<PlaceSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'jsonv2',
          'q': trimmed,
          'countrycodes': 'iq',
          'limit': 6,
          'accept-language': 'ar',
        },
        options: Options(
          headers: {'User-Agent': 'TaalaMobile/1.0 (com.mintops.taala)'},
        ),
      );

      final data = response.data;
      if (data == null) return [];

      return data
          .map((item) {
            final map = item as Map<String, dynamic>;
            final lat = double.tryParse(map['lat']?.toString() ?? '');
            final lng = double.tryParse(map['lon']?.toString() ?? '');
            final name = map['display_name']?.toString();
            if (lat == null || lng == null || name == null || name.isEmpty) {
              return null;
            }
            return PlaceSuggestion(
              displayName: name,
              latitude: lat,
              longitude: lng,
            );
          })
          .whereType<PlaceSuggestion>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
