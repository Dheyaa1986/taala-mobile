import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const _distance = Distance();

double navigationDistanceMeters(LatLng a, LatLng b) {
  return _distance.as(LengthUnit.Meter, a, b);
}

double navigationBearingDegrees(LatLng from, LatLng to) {
  return _distance.bearing(from, to);
}

/// Minimum distance from [point] to any segment of [polyline] (meters).
double distanceToPolylineMeters(LatLng point, List<LatLng> polyline) {
  if (polyline.isEmpty) return double.infinity;
  if (polyline.length == 1) {
    return navigationDistanceMeters(point, polyline.first);
  }

  var minDistance = double.infinity;
  for (var i = 0; i < polyline.length - 1; i++) {
    final segmentDistance =
        _distanceToSegmentMeters(point, polyline[i], polyline[i + 1]);
    if (segmentDistance < minDistance) {
      minDistance = segmentDistance;
    }
  }
  return minDistance;
}

/// Closest point on [polyline] to [point] (road centerline).
LatLng closestPointOnPolyline(LatLng point, List<LatLng> polyline) {
  if (polyline.isEmpty) return point;
  if (polyline.length == 1) return polyline.first;

  LatLng best = polyline.first;
  var bestDistance = double.infinity;
  for (var i = 0; i < polyline.length - 1; i++) {
    final candidate = _closestPointOnSegment(point, polyline[i], polyline[i + 1]);
    final d = navigationDistanceMeters(point, candidate);
    if (d < bestDistance) {
      bestDistance = d;
      best = candidate;
    }
  }
  return best;
}

/// Index of the polyline vertex closest to [point].
int closestPolylineIndex(LatLng point, List<LatLng> polyline) {
  if (polyline.isEmpty) return 0;

  var bestIndex = 0;
  var bestDistance = double.infinity;
  for (var i = 0; i < polyline.length; i++) {
    final d = navigationDistanceMeters(point, polyline[i]);
    if (d < bestDistance) {
      bestDistance = d;
      bestIndex = i;
    }
  }
  return bestIndex;
}

/// Remaining route distance from [point] along [polyline] (meters).
double remainingPolylineDistanceMeters(LatLng point, List<LatLng> polyline) {
  if (polyline.length < 2) return 0;

  final index = closestPolylineIndex(point, polyline);
  var total = navigationDistanceMeters(point, polyline[index]);
  for (var i = index; i < polyline.length - 1; i++) {
    total += navigationDistanceMeters(polyline[i], polyline[i + 1]);
  }
  return total;
}

LatLng _closestPointOnSegment(LatLng p, LatLng a, LatLng b) {
  final ax = a.longitude;
  final ay = a.latitude;
  final bx = b.longitude;
  final by = b.latitude;
  final px = p.longitude;
  final py = p.latitude;

  final abx = bx - ax;
  final aby = by - ay;
  final apx = px - ax;
  final apy = py - ay;
  final abLenSq = abx * abx + aby * aby;
  if (abLenSq == 0) return a;

  final t = ((apx * abx + apy * aby) / abLenSq).clamp(0.0, 1.0);
  return LatLng(ay + aby * t, ax + abx * t);
}

double _distanceToSegmentMeters(LatLng p, LatLng a, LatLng b) {
  return navigationDistanceMeters(p, _closestPointOnSegment(p, a, b));
}

String formatNavigationDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} كم';
  }
  return '${meters.round()} م';
}

int formatNavigationDurationMinutes(double seconds) {
  return math.max(1, (seconds / 60).round());
}
