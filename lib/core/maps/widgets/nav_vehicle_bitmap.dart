import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:taal/core/maps/widgets/nav_vehicle_marker.dart';

Future<gmaps.BitmapDescriptor> createNavVehicleBitmap({
  double logicalSize = 48,
}) async {
  const pixelRatio = 3.0;
  final pixelSize = (logicalSize * pixelRatio).round();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  NavVehicleChevronPainter().paint(
    canvas,
    Size(pixelSize.toDouble(), pixelSize.toDouble()),
  );
  final image = await recorder.endRecording().toImage(pixelSize, pixelSize);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    return gmaps.BitmapDescriptor.defaultMarkerWithHue(
      gmaps.BitmapDescriptor.hueAzure,
    );
  }
  return gmaps.BitmapDescriptor.bytes(
    bytes.buffer.asUint8List(),
    width: logicalSize,
    height: logicalSize,
  );
}
