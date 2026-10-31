import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.imageUrl,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final double? distanceMeters;
  final String? imageUrl;
}

class PlaceSearchService {
  PlaceSearchService()
      : _dio = Dio(
          BaseOptions(
            headers: {
              'User-Agent': _userAgent,
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  static const _userAgent =
      'TaalaMobile/1.0.19 (com.mintops.taala; https://taal1.com)';

  static const _overpassEndpoints = <String>[
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass-api.de/api/interpreter',
  ];

  final Dio _dio;

  Future<List<PlaceSuggestion>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];

    try {
      final response = await _dio.get<dynamic>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'jsonv2',
          'q': trimmed,
          'countrycodes': 'iq',
          'limit': 6,
          'accept-language': 'ar,en',
          'namedetails': 1,
          'extratags': 1,
        },
      );
      return _parseNominatimList(response.data);
    } catch (_) {
      return [];
    }
  }

  Future<List<PlaceSuggestion>> searchNearby({
    required double latitude,
    required double longitude,
    required String overpassFilter,
    List<String> overpassFilters = const [],
    List<String> searchQueries = const [],
    int radiusMeters = 8000,
    int limit = 30,
  }) async {
    final queries = searchQueries
        .map((query) => query.trim())
        .where((query) => query.isNotEmpty)
        .toList();
    if (queries.isEmpty) {
      queries.add(overpassFilter);
    }

    final photon = await _searchPhotonNearby(
      latitude: latitude,
      longitude: longitude,
      queries: queries,
      radiusMeters: radiusMeters,
      limit: limit,
    );
    if (photon.isNotEmpty) return photon;

    final nominatim = await _searchNominatimNearby(
      latitude: latitude,
      longitude: longitude,
      queries: queries,
      radiusMeters: radiusMeters,
      limit: limit,
    );
    if (nominatim.isNotEmpty) return nominatim;

    return _searchOverpassNearby(
      latitude: latitude,
      longitude: longitude,
      filters: overpassFilters.isNotEmpty ? overpassFilters : [overpassFilter],
      radiusMeters: radiusMeters,
      limit: limit,
    );
  }

  Future<List<PlaceSuggestion>> _searchPhotonNearby({
    required double latitude,
    required double longitude,
    required List<String> queries,
    required int radiusMeters,
    required int limit,
  }) async {
    final merged = <PlaceSuggestion>[];
    for (final query in queries) {
      try {
        final response = await _dio.get<dynamic>(
          'https://photon.komoot.io/api/',
          queryParameters: {
            'q': query,
            'lat': latitude,
            'lon': longitude,
            'limit': 40,
            'lang': 'default',
          },
        );
        final features = response.data is Map
            ? (response.data as Map)['features']
            : null;
        if (features is! List) continue;
        for (final raw in features) {
          if (raw is! Map) continue;
          final feature = Map<String, dynamic>.from(raw);
          final geometry = feature['geometry'] is Map
              ? Map<String, dynamic>.from(feature['geometry'] as Map)
              : null;
          final coords = geometry?['coordinates'];
          if (coords is! List || coords.length < 2) continue;
          final lng = (coords[0] as num?)?.toDouble();
          final lat = (coords[1] as num?)?.toDouble();
          if (lat == null || lng == null) continue;
          final properties = feature['properties'] is Map
              ? Map<String, dynamic>.from(feature['properties'] as Map)
              : <String, dynamic>{};
          final country = properties['countrycode']?.toString().toUpperCase();
          if (country != null && country.isNotEmpty && country != 'IQ') {
            continue;
          }
          final name = _composeDisplayName(
            primary: properties['name']?.toString(),
            arabic: properties['name']?.toString(),
            english: null,
            fallback: properties['street']?.toString() ??
                properties['city']?.toString(),
          );
          if (name.isEmpty) continue;
          merged.add(
            PlaceSuggestion(
              displayName: name,
              latitude: lat,
              longitude: lng,
              distanceMeters: _distanceMeters(latitude, longitude, lat, lng),
            ),
          );
        }
      } catch (_) {
        continue;
      }
      final filtered = _dedupeAndLimit(
        merged,
        radiusMeters: radiusMeters,
        limit: limit,
      );
      if (filtered.length >= 8) return filtered;
    }
    return _dedupeAndLimit(
      merged,
      radiusMeters: radiusMeters,
      limit: limit,
    );
  }

  Future<List<PlaceSuggestion>> _searchNominatimNearby({
    required double latitude,
    required double longitude,
    required List<String> queries,
    required int radiusMeters,
    required int limit,
  }) async {
    final deltaLat = radiusMeters / 111000.0;
    final cosLat = math.cos(_toRad(latitude)).abs().clamp(0.2, 1.0);
    final deltaLng = radiusMeters / (111000.0 * cosLat);
    final viewbox =
        '${longitude - deltaLng},${latitude + deltaLat},${longitude + deltaLng},${latitude - deltaLat}';
    final merged = <PlaceSuggestion>[];
    for (final query in queries) {
      try {
        final response = await _dio.get<dynamic>(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'format': 'jsonv2',
            'q': query,
            'lat': latitude,
            'lon': longitude,
            'countrycodes': 'iq',
            'limit': 20,
            'bounded': 1,
            'viewbox': viewbox,
            'accept-language': 'ar,en',
            'namedetails': 1,
            'extratags': 1,
          },
        );
        merged.addAll(
          _parseNominatimList(
            response.data,
            originLat: latitude,
            originLng: longitude,
          ),
        );
      } catch (_) {
        continue;
      }
      final filtered = _dedupeAndLimit(
        merged,
        radiusMeters: radiusMeters,
        limit: limit,
      );
      if (filtered.length >= 8) return filtered;
    }
    return _dedupeAndLimit(
      merged,
      radiusMeters: radiusMeters,
      limit: limit,
    );
  }

  Future<List<PlaceSuggestion>> _searchOverpassNearby({
    required double latitude,
    required double longitude,
    required List<String> filters,
    required int radiusMeters,
    required int limit,
  }) async {
    final clauses = filters
        .map(
          (filter) =>
              '  nwr$filter(around:$radiusMeters,$latitude,$longitude);',
        )
        .join('\n');
    final query = '''
[out:json][timeout:12];
(
$clauses
);
out center $limit;
''';
    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await _dio.post<dynamic>(
          endpoint,
          data: {'data': query},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 14),
            sendTimeout: const Duration(seconds: 10),
          ),
        );
        final decoded = jsonDecode(response.data?.toString() ?? '');
        if (decoded is! Map) continue;
        final parsed = _parseNearbyElements(
          decoded['elements'],
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

  List<PlaceSuggestion> _parseNominatimList(
    dynamic data, {
    double? originLat,
    double? originLng,
  }) {
    if (data is! List) return [];
    final results = <PlaceSuggestion>[];
    for (final item in data) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final lat = double.tryParse(map['lat']?.toString() ?? '');
      final lng = double.tryParse(map['lon']?.toString() ?? '');
      final details = map['namedetails'] is Map
          ? Map<String, dynamic>.from(map['namedetails'] as Map)
          : <String, dynamic>{};
      final name = _composeDisplayName(
        primary: map['name']?.toString() ?? map['display_name']?.toString(),
        arabic: details['name:ar']?.toString() ?? map['name']?.toString(),
        english: details['name:en']?.toString(),
        fallback: map['display_name']?.toString(),
      );
      if (lat == null || lng == null || name.isEmpty) {
        continue;
      }
      final extras = map['extratags'] is Map
          ? Map<String, dynamic>.from(map['extratags'] as Map)
          : <String, dynamic>{};
      results.add(
        PlaceSuggestion(
          displayName: name,
          latitude: lat,
          longitude: lng,
          distanceMeters: originLat == null || originLng == null
              ? null
              : _distanceMeters(originLat, originLng, lat, lng),
          imageUrl: _imageFromTags(extras),
        ),
      );
    }
    return results;
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
      final name = _composeDisplayName(
        primary: tags['name']?.toString(),
        arabic: tags['name:ar']?.toString() ?? tags['name']?.toString(),
        english: tags['name:en']?.toString(),
        fallback: _placeLabel(tags),
      );
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
          imageUrl: _imageFromTags(tags),
        ),
      );
    }
    return _dedupeAndLimit(
      results,
      radiusMeters: 20000,
      limit: limit,
    );
  }

  List<PlaceSuggestion> _dedupeAndLimit(
    List<PlaceSuggestion> input, {
    required int radiusMeters,
    required int limit,
  }) {
    final seen = <String, int>{};
    final results = <PlaceSuggestion>[];
    for (final place in input) {
      final distance = place.distanceMeters;
      if (distance != null && distance > radiusMeters) continue;
      final key =
          '${place.latitude.toStringAsFixed(5)}|${place.longitude.toStringAsFixed(5)}';
      final existingIndex = seen[key];
      if (existingIndex != null) {
        final existing = results[existingIndex];
        if ((existing.imageUrl == null || existing.imageUrl!.isEmpty) &&
            place.imageUrl != null &&
            place.imageUrl!.isNotEmpty) {
          results[existingIndex] = place;
        }
        continue;
      }
      seen[key] = results.length;
      results.add(place);
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
      if (value != null && value.isNotEmpty) {
        return _arabicKnownLabel(value) ?? value;
      }
    }
    return '';
  }

  static final _arabicScript = RegExp(r'[\u0600-\u06FF]');

  bool _hasArabic(String value) => _arabicScript.hasMatch(value);

  String? _arabicKnownLabel(String value) {
    const labels = <String, String>{
      'hospital': 'مستشفى',
      'clinic': 'عيادة',
      'doctors': 'عيادة',
      'restaurant': 'مطعم',
      'fast_food': 'وجبات سريعة',
      'cafe': 'مقهى',
      'charging_station': 'محطة شحن',
      'fuel': 'محطة وقود',
      'supermarket': 'سوبرماركت',
      'convenience': 'بقالة',
      'mall': 'مول',
      'bank': 'مصرف',
      'atm': 'صراف آلي',
      'place_of_worship': 'مسجد',
      'mosque': 'مسجد',
      'bus_station': 'محطة باص',
      'bus_stop': 'موقف باص',
      'station': 'محطة',
      'park': 'حديقة',
      'pharmacy': 'صيدلية',
    };
    final key = value.trim().toLowerCase();
    return labels[key] ?? labels[key.replaceAll(' ', '_')];
  }

  String _composeDisplayName({
    String? primary,
    String? arabic,
    String? english,
    String? fallback,
  }) {
    final candidates = <String>[
      if (arabic != null) arabic,
      if (primary != null) primary,
      if (english != null) english,
      if (fallback != null) fallback,
    ]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (candidates.isEmpty) return '';

    String? ar;
    String? en;
    for (final value in candidates) {
      final known = _arabicKnownLabel(value);
      if (known != null) {
        ar ??= known;
        continue;
      }
      if (_hasArabic(value)) {
        ar ??= value.split(',').first.trim();
      } else {
        en ??= value.split(',').first.trim();
      }
    }

    if (ar != null && en != null && ar != en) {
      return '$ar ($en)';
    }
    return ar ?? en ?? candidates.first.split(',').first.trim();
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

  String? _imageFromTags(Map<String, dynamic> tags) {
    for (final key in ['image', 'image:logo', 'logo', 'brand:logo']) {
      final url = _safeImageUrl(tags[key]?.toString());
      if (url != null) return url;
    }
    return _safeImageUrl(tags['wikimedia_commons']?.toString());
  }

  String? _safeImageUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.startsWith('javascript:') || lower.startsWith('data:')) {
      return null;
    }
    if (lower.startsWith('file:')) {
      final fileName = value.substring(5).trim();
      if (fileName.isEmpty || fileName.contains('..')) return null;
      return 'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(fileName)}?width=128';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (uri.host.isEmpty) return null;
    return uri.replace(scheme: 'https').toString();
  }
}
