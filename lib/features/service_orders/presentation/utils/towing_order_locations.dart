import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';

class TowingDestinationPayload {
  const TowingDestinationPayload({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class TowingOrderLocations {
  static const towingCategoryCode = 'TOWING';

  static bool isTowingCategory(String? code) =>
      code?.toUpperCase() == towingCategoryCode;

  static bool isTowingOrder(ServiceOrderModel order) =>
      isTowingCategory(order.serviceType?.categoryCode);

  static Future<TowingDestinationPayload?> readDestinationFromPrefs(
    SharedPref prefs,
  ) async {
    final address = await prefs.get(key: PrefsKeys.destinationLocationAddress);
    final lat = await prefs.get(key: PrefsKeys.destinationLocationLat);
    final lng = await prefs.get(key: PrefsKeys.destinationLocationLng);

    final parsedLat = lat is String ? double.tryParse(lat) : null;
    final parsedLng = lng is String ? double.tryParse(lng) : null;
    final trimmedAddress = address is String ? address.trim() : '';

    if (parsedLat == null ||
        parsedLng == null ||
        trimmedAddress.isEmpty) {
      return null;
    }

    return TowingDestinationPayload(
      address: trimmedAddress,
      latitude: parsedLat,
      longitude: parsedLng,
    );
  }
}
