import 'dart:async';

import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

class ProviderLiveLocationService {
  ProviderLiveLocationService({
    DeviceLocationService? deviceLocation,
    ProfileRepository? profileRepository,
  })  : _deviceLocation = deviceLocation ?? getIt<DeviceLocationService>(),
        _profileRepository = profileRepository ?? getIt<ProfileRepository>();

  final DeviceLocationService _deviceLocation;
  final ProfileRepository _profileRepository;
  Timer? _timer;
  bool _isAvailable = false;

  bool get isTracking => _timer != null;

  Future<void> setAvailability(bool isAvailable) async {
    _isAvailable = isAvailable;
    await _profileRepository.updateProviderAvailability(
      isAvailable: isAvailable,
    );

    if (isAvailable) {
      await _sendCurrentLocation();
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) {
      _sendCurrentLocation();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendCurrentLocation() async {
    if (!_isAvailable) return;
    final location = await _deviceLocation.getCurrentLocation();
    if (location == null) return;
    await _profileRepository.updateProviderLiveLocation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  void dispose() {
    _stopTimer();
  }
}
