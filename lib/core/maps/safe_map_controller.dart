import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Guards [MapController] calls until [FlutterMap] has rendered once.
class SafeMapController {
  SafeMapController(this._controller);

  final MapController _controller;
  bool _ready = false;

  void markReady() {
    _ready = true;
  }

  void move(LatLng center, double zoom, {double? bearing}) {
    if (!_ready) return;
    try {
      _controller.move(center, zoom);
      if (bearing != null) {
        _controller.rotate(-bearing);
      }
    } catch (error, stackTrace) {
      debugPrint('SafeMapController.move skipped: $error\n$stackTrace');
    }
  }

  void fitCamera(CameraFit fit) {
    if (!_ready) return;
    try {
      _controller.fitCamera(fit);
    } catch (error, stackTrace) {
      debugPrint('SafeMapController.fitCamera skipped: $error\n$stackTrace');
    }
  }
}
