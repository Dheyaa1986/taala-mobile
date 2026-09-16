import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';

class OrderLocationPrefsValidators {
  static bool hasCoordinates(PickedLocation? location) =>
      location != null &&
      location.latitude.isFinite &&
      location.longitude.isFinite;

  static bool isValidClient(PickedLocation? location) =>
      hasCoordinates(location);

  static bool isValidDestination(PickedLocation? location) =>
      hasCoordinates(location);
}

class OrderLocationPrefs {
  static String coordinateLabel(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  static PickedLocation withResolvedAddress(PickedLocation location) {
    final trimmed = location.address?.trim() ?? '';
    if (trimmed.isNotEmpty) return location;
    return PickedLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      address: coordinateLabel(location.latitude, location.longitude),
    );
  }

  static Future<PickedLocation> ensureAddress(
    PickedLocation location,
    ReverseGeocodingService geocoding,
  ) async {
    if (location.address?.trim().isNotEmpty ?? false) {
      return location;
    }
    final address = await geocoding.resolveAddress(
      location.latitude,
      location.longitude,
    );
    if (address != null && address.trim().isNotEmpty) {
      return PickedLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address.trim(),
      );
    }
    return withResolvedAddress(location);
  }

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

  static Future<PickedLocation?> readDestination(SharedPref prefs) async {
    final lat = await prefs.get(key: PrefsKeys.destinationLocationLat);
    final lng = await prefs.get(key: PrefsKeys.destinationLocationLng);
    final address = await prefs.get(key: PrefsKeys.destinationLocationAddress);
    if (lat is! String || lng is! String) return null;
    final parsedLat = double.tryParse(lat);
    final parsedLng = double.tryParse(lng);
    if (parsedLat == null || parsedLng == null) return null;
    final trimmedAddress = address is String ? address.trim() : '';
    return PickedLocation(
      latitude: parsedLat,
      longitude: parsedLng,
      address: trimmedAddress.isNotEmpty
          ? trimmedAddress
          : coordinateLabel(parsedLat, parsedLng),
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
    final trimmedAddress = address is String ? address.trim() : '';
    return PickedLocation(
      latitude: parsedLat,
      longitude: parsedLng,
      address: trimmedAddress.isNotEmpty
          ? trimmedAddress
          : coordinateLabel(parsedLat, parsedLng),
    );
  }
}
