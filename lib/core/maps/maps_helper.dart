import 'package:latlong2/latlong.dart';

class MapsHelper {
  static const LatLng defaultCenter = LatLng(33.3152, 44.3661);

  static String googleMapsUrl(double lat, double lng) {
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  static LatLng? parseFromGoogleUrl(String url) {
    final normalized = url.trim();
    if (normalized.isEmpty) return null;

    final atMatch = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(normalized);
    if (atMatch != null) {
      return _toLatLng(atMatch.group(1), atMatch.group(2));
    }

    final qMatch = RegExp(r'[?&]q=(-?\d+\.?\d*),(-?\d+\.?\d*)')
        .firstMatch(normalized);
    if (qMatch != null) {
      return _toLatLng(qMatch.group(1), qMatch.group(2));
    }

    return null;
  }

  static LatLng? _toLatLng(String? lat, String? lng) {
    final parsedLat = double.tryParse(lat ?? '');
    final parsedLng = double.tryParse(lng ?? '');
    if (parsedLat == null || parsedLng == null) return null;
    return LatLng(parsedLat, parsedLng);
  }
}
