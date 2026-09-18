import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'device_location_reading.dart';
import 'navigation/navigation_geometry.dart';
import 'picked_location.dart';

class DeviceLocationService {
  final Location _location = Location();
  LatLng? _previousPoint;

  Future<PickedLocation?> getCurrentLocation() async {
    final reading = await getNavigationReading();
    if (reading == null) return null;
    return PickedLocation(
      latitude: reading.latitude,
      longitude: reading.longitude,
    );
  }

  Future<DeviceLocationReading?> getNavigationReading() async {
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
    var heading = data.heading;
    if (heading == null || heading < 0) {
      final previous = _previousPoint;
      if (previous != null) {
        final moved = navigationDistanceMeters(previous, current);
        if (moved >= 4) {
          heading = navigationBearingDegrees(previous, current);
        }
      }
    }

    _previousPoint = current;

    return DeviceLocationReading(
      latitude: lat,
      longitude: lng,
      heading: heading,
      speedMps: data.speed,
    );
  }
}
