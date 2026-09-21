import 'google_maps_local_token.dart';
import 'google_maps_local_token.sample.dart' as sample;

/// Google Maps API key resolution (Maps SDK + Directions API).
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const _envKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static String? get apiKey {
    if (_envKey.isNotEmpty) return _envKey;
    if (kGoogleMapsLocalApiKey.isNotEmpty) return kGoogleMapsLocalApiKey;
    if (sample.kGoogleMapsLocalApiKey.isNotEmpty) {
      return sample.kGoogleMapsLocalApiKey;
    }
    return null;
  }

  static bool get isEnabled =>
      apiKey != null && apiKey!.trim().isNotEmpty;
}
