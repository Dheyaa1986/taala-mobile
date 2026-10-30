import 'dart:math' as math;

import 'package:dio/dio.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
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

  static const _overpassEndpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  Future<List<PlaceSuggestion>> searchNearby({
    required double latitude,
    required double longitude,
    required String overpassFilter,
    List<String> overpassFilters = const [],
    int radiusMeters = 8000,
    int limit = 30,
  }) async {
    final filters = overpassFilters.isNotEmpty
        ? overpassFilters
        : [overpassFilter];
    final clauses = filters
        .map(
          (filter) =>
              '  nwr$filter(around:$radiusMeters,$latitude,$longitude);',
        )
        .join('\n');
    final query = '''
[out:json][timeout:25];
(
$clauses
);
out center $limit;
''';
    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          endpoint,
          data: {'data': query},
          options: Options(
            headers: {'User-Agent': 'TaalaMobile/1.0 (com.mintops.taala)'},
            contentType: Headers.formUrlEncodedContentType,
            receiveTimeout: const Duration(seconds: 28),
            sendTimeout: const Duration(seconds: 20),
          ),
        );
        final parsed = _parseNearbyElements(
          response.data?['elements'],
          originLat: latitude,
          originLng: longitude,
          limit: limit,
        );
        if (parsed.isNotEmpty) return parsed;
      } catch (_) {
        continue;
      }
    }
    return [];
  }

  List<PlaceSuggestion> _parseNearbyElements(
    dynamic elements, {
    required double originLat,
    required double originLng,
    required int limit,
  }) {
    if (elements is! List) return [];
    final results = <PlaceSuggestion>[];
    for (final raw in elements) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final tags = map['tags'] is Map
          ? Map<String, dynamic>.from(map['tags'] as Map)
          : <String, dynamic>{};
      final lat = (map['lat'] as num?)?.toDouble() ??
          (map['center'] is Map
              ? (map['center']['lat'] as num?)?.toDouble()
              : null);
      final lng = (map['lon'] as num?)?.toDouble() ??
          (map['center'] is Map
              ? (map['center']['lon'] as num?)?.toDouble()
              : null);
      if (lat == null || lng == null) continue;
      final name = _placeLabel(tags);
      if (name.isEmpty) continue;
      results.add(
        PlaceSuggestion(
          displayName: name,
          latitude: lat,
          longitude: lng,
          distanceMeters: _distanceMeters(
            originLat,
            originLng,
            lat,
            lng,
          ),
        ),
      );
    }
    results.sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );
    if (results.length <= limit) return results;
    return results.take(limit).toList();
  }

  String _placeLabel(Map<String, dynamic> tags) {
    for (final key in [
      'name:ar',
      'name',
      'name:en',
      'brand',
      'operator',
      'amenity',
      'shop',
      'leisure',
      'healthcare',
    ]) {
      final value = tags[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earth = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRad(double degrees) => degrees * 3.141592653589793 / 180;
}
