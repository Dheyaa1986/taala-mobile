import 'package:location/location.dart';

import 'picked_location.dart';

class DeviceLocationService {
  final Location _location = Location();

  Future<PickedLocation?> getCurrentLocation() async {
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

    return PickedLocation(latitude: lat, longitude: lng);
  }
}
