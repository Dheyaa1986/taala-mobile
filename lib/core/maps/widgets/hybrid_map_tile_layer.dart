import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:taal/core/maps/map_style_config.dart';

class HybridMapTileLayer {
  const HybridMapTileLayer._();

  static List<Widget> layers({
    String? offlineMapPath,
    List<String> offlineMapPaths = const [],
  }) {
    final paths = <String>[];
    for (final path in [
      ...offlineMapPaths,
      if (offlineMapPath != null) offlineMapPath,
    ]) {
      if (path.isEmpty || paths.contains(path)) continue;
      if (File(path).existsSync()) paths.add(path);
    }

    return [
      TileLayer(
        urlTemplate: MapStyleConfig.tileUrlTemplate,
        subdomains: MapStyleConfig.tileSubdomains,
        userAgentPackageName: MapStyleConfig.userAgentPackageName,
        maxZoom: 19,
      ),
      for (final path in paths)
        TileLayer(
          tileProvider: MbTilesTileProvider.fromPath(path: path),
          maxZoom: 19,
        ),
    ];
  }
}
