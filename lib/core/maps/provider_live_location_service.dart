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
  Timer? _tripTimer;
  bool _isAvailable = false;
  bool _tripActive = false;

  bool get isTracking => _timer != null;
  bool get isTripTracking => _tripActive;

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

  Future<void> startTripTracking() async {
    _tripActive = true;
    await _sendCurrentLocation();
    _stopTripTimer();
    _tripTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendCurrentLocation();
    });
  }

  void stopTripTracking() {
    _tripActive = false;
    _stopTripTimer();
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

  void _stopTripTimer() {
    _tripTimer?.cancel();
    _tripTimer = null;
  }

  Future<void> _sendCurrentLocation() async {
    if (!_isAvailable && !_tripActive) return;
    final location = await _deviceLocation.getCurrentLocation();
    if (location == null) return;
    await _profileRepository.updateProviderLiveLocation(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  void dispose() {
    _stopTimer();
    _stopTripTimer();
  }
}
