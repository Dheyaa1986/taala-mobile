import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';

extension ServiceProviderMapPoint on ServiceProviderModel {
  LatLng? get mapPoint {
    for (final location in locations) {
      final lat = double.tryParse(location.lat ?? '');
      final lng = double.tryParse(location.lng ?? '');
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }

      final link = location.googleMapsUrl;
      if (link != null && link.isNotEmpty) {
        final coords = MapsHelper.parseFromGoogleUrl(link);
        if (coords != null) {
          return LatLng(coords.latitude, coords.longitude);
        }
      }
    }

    return null;
  }
}
