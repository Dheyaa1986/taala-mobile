import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/picked_location.dart';

class OrderLocationPrefs {
  static Future<void> saveClient(
    SharedPref prefs,
    PickedLocation location,
  ) async {
    await prefs.set(
      key: PrefsKeys.clientLocationAddress,
      value: location.address?.trim() ?? '',
    );
    await prefs.set(
      key: PrefsKeys.clientLocationMapLink,
      value: location.googleMapsUrl,
    );
    await prefs.set(key: PrefsKeys.clientLocationLat, value: location.lat);
    await prefs.set(key: PrefsKeys.clientLocationLng, value: location.lng);
  }

  static Future<void> saveDestination(
    SharedPref prefs,
    PickedLocation location,
  ) async {
    await prefs.set(
      key: PrefsKeys.destinationLocationAddress,
      value: location.address?.trim() ?? '',
    );
    await prefs.set(
      key: PrefsKeys.destinationLocationMapLink,
      value: location.googleMapsUrl,
    );
    await prefs.set(
      key: PrefsKeys.destinationLocationLat,
      value: location.lat,
    );
    await prefs.set(
      key: PrefsKeys.destinationLocationLng,
      value: location.lng,
    );
  }

  static Future<PickedLocation?> readClient(SharedPref prefs) async {
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    if (lat is! String || lng is! String) return null;
    final parsedLat = double.tryParse(lat);
    final parsedLng = double.tryParse(lng);
    if (parsedLat == null || parsedLng == null) return null;
    return PickedLocation(
      latitude: parsedLat,
      longitude: parsedLng,
      address: address is String ? address : null,
    );
  }
}
