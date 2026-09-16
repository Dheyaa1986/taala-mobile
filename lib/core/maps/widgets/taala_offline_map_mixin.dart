import 'package:flutter/material.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/offline/map_offline_manager.dart';

/// Loads local MBTiles path for [HybridMapTileLayer] when available.
mixin TaalaOfflineMapMixin<T extends StatefulWidget> on State<T> {
  String? offlineMapPath;

  Future<void> refreshOfflineMapPath(double lat, double lng) async {
    final path = await getIt<MapOfflineManager>().localMapPathFor(lat, lng);
    if (!mounted) return;
    setState(() => offlineMapPath = path);
  }
}
