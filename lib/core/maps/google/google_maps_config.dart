import 'google_maps_local_token.sample.dart' as sample;

/// Google Maps API key resolution (Maps SDK + Directions API).
///
/// CI/Codemagic: pass `--dart-define=GOOGLE_MAPS_API_KEY=...`.
/// Local optional file `google_maps_local_token.dart` is gitignored and
/// must not be imported here or release builds fail.
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const _envKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  static String? get apiKey {
    if (_envKey.isNotEmpty) return _envKey;
    if (sample.kGoogleMapsLocalApiKey.isNotEmpty) {
      return sample.kGoogleMapsLocalApiKey;
    }
    return null;
  }

  static bool get isEnabled =>
      apiKey != null && apiKey!.trim().isNotEmpty;
}
