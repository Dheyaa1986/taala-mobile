import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'google_maps_local_token.sample.dart' as sample;

/// Google Maps API key resolution (Maps SDK + Directions API).
///
/// Android: native key in gitignored
/// `android/app/src/main/res/values/google_maps_api.xml` (Manifest meta-data).
/// Dart reads that same key at runtime so انطلق uses in-app Google maps
/// without duplicating the secret in Git.
///
/// Optional override: `--dart-define=GOOGLE_MAPS_API_KEY=...`.
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static const _envKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const _channel = MethodChannel('com.mintops.taala/maps');
  static String? _nativeKey;

  static Future<void> hydrateNativeKey() async {
    if (kIsWeb) return;
    try {
      final key = await _channel.invokeMethod<String>('googleMapsApiKey');
      final trimmed = key?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        _nativeKey = trimmed;
      }
    } catch (_) {}
  }

  static String? get apiKey {
    if (_envKey.isNotEmpty) return _envKey;
    if (_nativeKey != null && _nativeKey!.isNotEmpty) return _nativeKey;
    if (sample.kGoogleMapsLocalApiKey.isNotEmpty) {
      return sample.kGoogleMapsLocalApiKey;
    }
    return null;
  }

  static bool get useGoogleMapWidget =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.ios);

  static bool get isEnabled =>
      useGoogleMapWidget || (apiKey != null && apiKey!.trim().isNotEmpty);
}
