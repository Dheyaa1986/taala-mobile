import 'package:flutter/material.dart';

class MapStyleConfig {
  const MapStyleConfig._();

  static const String userAgentPackageName = 'com.mintops.taala';

  /// Carto Positron — pale streets, closer to a navigation / Waze daytime look.
  static const String tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  static const List<String> tileSubdomains = ['a', 'b', 'c', 'd'];

  static const Color routeColor = Color(0xFF33B5E5);
  static const Color routeCasingColor = Color(0xFF0D47A1);
  static const double routeWidth = 7;
  static const double routeCasingWidth = 11;

  /// Muted Google basemap so the cyan route reads like in-app navigation.
  static const String googleNavigationMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f2f2f2"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},
  {"featureType":"poi","stylers":[{"visibility":"simplified"}]},
  {"featureType":"poi.business","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#e6e6e6"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9e4f5"}]}
]
''';

  static const double defaultLatitude = 33.3152;
  static const double defaultLongitude = 44.3661;
  static const double defaultZoom = 13;
}
