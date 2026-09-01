import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:taal/core/maps/map_style_config.dart';

class HybridMapTileLayer extends StatelessWidget {
  const HybridMapTileLayer({
    super.key,
    this.offlineMapPath,
  });

  final String? offlineMapPath;

  @override
  Widget build(BuildContext context) {
    final path = offlineMapPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return TileLayer(
        tileProvider: MbTilesTileProvider.fromPath(path: path),
        maxZoom: 19,
      );
    }

    return TileLayer(
      urlTemplate: MapStyleConfig.tileUrlTemplate,
      subdomains: MapStyleConfig.tileSubdomains,
      userAgentPackageName: MapStyleConfig.userAgentPackageName,
      maxZoom: 19,
    );
  }
}
