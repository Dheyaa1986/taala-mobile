class MapStyleConfig {
  const MapStyleConfig._();

  static const String userAgentPackageName = 'com.mintops.taala';

  /// Carto Voyager — clean modern 2D style, free for app usage.
  static const String tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  static const List<String> tileSubdomains = ['a', 'b', 'c', 'd'];

  static const double defaultLatitude = 33.3152;
  static const double defaultLongitude = 44.3661;
  static const double defaultZoom = 13;
}
