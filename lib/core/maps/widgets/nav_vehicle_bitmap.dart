import 'dart:math' as math;
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

Future<gmaps.BitmapDescriptor> createLabeledPinBitmap({
  required String label,
  required Color color,
}) async {
  const pixelRatio = 3.0;
  const logicalWidth = 108.0;
  const logicalHeight = 86.0;
  final width = (logicalWidth * pixelRatio).round();
  final height = (logicalHeight * pixelRatio).round();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(width.toDouble(), height.toDouble());

  final pinWidth = 36 * pixelRatio;
  final pinHeight = 48 * pixelRatio;
  final pinTop = 4 * pixelRatio;
  final cx = size.width / 2;
  final pin = Path()
    ..addOval(
      Rect.fromCircle(
        center: Offset(cx, pinTop + pinWidth / 2),
        radius: pinWidth / 2,
      ),
    )
    ..moveTo(cx - pinWidth * 0.32, pinTop + pinWidth * 0.72)
    ..lineTo(cx, pinTop + pinHeight)
    ..lineTo(cx + pinWidth * 0.32, pinTop + pinWidth * 0.72)
    ..close();

  canvas.drawPath(
    pin,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * pixelRatio
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawPath(pin, Paint()..color = color);

  final text = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 13 * pixelRatio,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
    maxLines: 1,
  )..layout(maxWidth: size.width - 8 * pixelRatio);

  final bg = RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(cx, pinTop + pinHeight + 6 * pixelRatio + text.height / 2),
      width: math.min(size.width - 4 * pixelRatio, text.width + 12 * pixelRatio),
      height: text.height + 6 * pixelRatio,
    ),
    Radius.circular(8 * pixelRatio),
  );
  canvas.drawRRect(bg, Paint()..color = Colors.white.withValues(alpha: 0.92));
  text.paint(
    canvas,
    Offset(cx - text.width / 2, pinTop + pinHeight + 6 * pixelRatio),
  );

  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    return gmaps.BitmapDescriptor.defaultMarkerWithHue(
      HSLColor.fromColor(color).hue,
    );
  }
  return gmaps.BitmapDescriptor.bytes(
    bytes.buffer.asUint8List(),
    width: logicalWidth,
    height: logicalHeight,
  );
}
