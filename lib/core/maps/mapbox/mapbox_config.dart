import 'mapbox_local_token.sample.dart';

/// Mapbox access token resolution.
///
/// Priority:
/// 1. `--dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx`
/// 2. [kMapboxLocalToken] in `mapbox_local_token.sample.dart` (local dev only)
class MapboxConfig {
  MapboxConfig._();

  static const _envToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static String? get accessToken {
    if (_envToken.isNotEmpty) return _envToken;
    if (kMapboxLocalToken.isNotEmpty) return kMapboxLocalToken;
    return null;
  }

  static bool get isEnabled =>
      accessToken != null && accessToken!.trim().isNotEmpty;
}
