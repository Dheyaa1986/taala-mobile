import 'package:flutter/material.dart';

class MapStyleConfig {
  const MapStyleConfig._();

  static const String userAgentPackageName = 'com.mintops.taala';

  /// Esri light-gray canvas — pale navigation look; Carto free tiles now require a key.
  static const String tileUrlTemplate =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}';

  static const List<String> tileSubdomains = <String>[];

  static const Color routeColor = Color(0xFF33B5E5);
  static const Color routeCasingColor = Color(0xFF0D47A1);
  static const double routeWidth = 9;
  static const double routeCasingWidth = 14;

  /// Daytime navigation basemap: pale land, white roads, muted POIs.
  static const String googleNavigationMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#ececec"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6b6b6b"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f7f7f7"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","stylers":[{"visibility":"simplified"},{"color":"#d7ead2"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#d4d4d4"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f3f3f3"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#dadada"}]},
  {"featureType":"road.local","elementType":"labels","stylers":[{"visibility":"simplified"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b7dff2"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5a9bb8"}]}
]
''';

  static const double defaultLatitude = 33.3152;
  static const double defaultLongitude = 44.3661;
  static const double defaultZoom = 13;
}
