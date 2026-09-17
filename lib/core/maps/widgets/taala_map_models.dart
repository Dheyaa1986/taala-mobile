import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TaalaMapMarker {
  const TaalaMapMarker({
    required this.point,
    required this.color,
    this.icon,
    this.iconSize = 32,
    this.livePulse = false,
  });

  final LatLng point;
  final Color color;
  final IconData? icon;
  final double iconSize;
  final bool livePulse;
}

class TaalaMapPolyline {
  const TaalaMapPolyline({
    required this.points,
    required this.color,
    this.width = 5,
    this.dashed = false,
  });

  final List<LatLng> points;
  final Color color;
  final double width;
  final bool dashed;
}
