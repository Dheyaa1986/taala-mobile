import 'package:flutter/material.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/offline/map_offline_manager.dart';

/// Loads local MBTiles paths for [HybridMapTileLayer] when available.
mixin TaalaOfflineMapMixin<T extends StatefulWidget> on State<T> {
  List<String> offlineMapPaths = [];

  String? get offlineMapPath =>
      offlineMapPaths.isEmpty ? null : offlineMapPaths.first;

  Future<void> refreshOfflineMapPath(double lat, double lng) async {
    final paths = await getIt<MapOfflineManager>().readyMapPaths();
    if (!mounted) return;
    setState(() => offlineMapPaths = paths);
  }
}
