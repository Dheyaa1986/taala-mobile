import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'device_location_reading.dart';
import 'navigation/navigation_geometry.dart';
import 'picked_location.dart';

class DeviceLocationService {
  final Location _location = Location();
  LatLng? _previousPoint;
  double? _compassHeading;
  double? _smoothedHeading;
  StreamSubscription<CompassEvent>? _compassSub;

  void startHeadingUpdates() {
    if (_compassSub != null) return;
    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null || heading.isNaN) return;
      var normalized = heading % 360;
      if (normalized < 0) normalized += 360;
      _compassHeading = normalized;
    });
  }

  void stopHeadingUpdates() {
    _compassSub?.cancel();
    _compassSub = null;
  }

  Future<PickedLocation?> getCurrentLocation() async {
    final reading = await getNavigationReading();
    if (reading == null) return null;
    return PickedLocation(
      latitude: reading.latitude,
      longitude: reading.longitude,
    );
  }

  Future<DeviceLocationReading?> getNavigationReading() async {
    startHeadingUpdates();
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return null;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        return null;
      }
    }

    final data = await _location.getLocation();
    final lat = data.latitude;
    final lng = data.longitude;
    if (lat == null || lng == null) return null;

    final current = LatLng(lat, lng);
    final speed = data.speed ?? 0;
    var heading = data.heading;
    if (heading == null || heading < 0 || heading.isNaN) {
      final previous = _previousPoint;
      if (previous != null) {
        final moved = navigationDistanceMeters(previous, current);
        if (moved >= 4) {
          heading = navigationBearingDegrees(previous, current);
        }
      }
    }

    if (speed < 2.5 && _compassHeading != null) {
      heading = _compassHeading;
    } else if ((heading == null || heading < 0) && _compassHeading != null) {
      heading = _compassHeading;
    }

    if (heading != null && heading >= 0) {
      _smoothedHeading = _smoothedHeading == null
          ? heading
          : _lerpHeading(_smoothedHeading!, heading, speed >= 2.5 ? 0.35 : 0.22);
      heading = _smoothedHeading;
    }

    _previousPoint = current;

    return DeviceLocationReading(
      latitude: lat,
      longitude: lng,
      heading: heading,
      speedMps: data.speed,
    );
  }

  double _lerpHeading(double from, double to, double t) {
    var delta = to - from;
    while (delta > 180) {
      delta -= 360;
    }
    while (delta < -180) {
      delta += 360;
    }
    var next = from + delta * t;
    next %= 360;
    if (next < 0) next += 360;
    return next;
  }
}
