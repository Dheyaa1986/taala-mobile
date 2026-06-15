import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:vibration/vibration.dart';

class AppAlertSoundService {
  AppAlertSoundService() {
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
  }

  final AudioPlayer _player = AudioPlayer();
  DateTime? _lastPlayedAt;

  bool get isEnabled {
    final value = getIt<SharedPref>().get(key: PrefsKeys.appAlertSoundEnabled);
    return value != false;
  }

  bool get vibrationEnabled {
    final value =
        getIt<SharedPref>().get(key: PrefsKeys.appAlertVibrationEnabled);
    return value != false;
  }

  double get volume {
    final value = getIt<SharedPref>().get(key: PrefsKeys.appAlertSoundVolume);
    if (value is num) {
      return value.clamp(0.5, 1.0).toDouble();
    }
    return 1.0;
  }

  Future<void> setEnabled(bool enabled) async {
    await getIt<SharedPref>().set(
      key: PrefsKeys.appAlertSoundEnabled,
      value: enabled,
    );
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await getIt<SharedPref>().set(
      key: PrefsKeys.appAlertVibrationEnabled,
      value: enabled,
    );
  }

  Future<void> setVolume(double value) async {
    await getIt<SharedPref>().set(
      key: PrefsKeys.appAlertSoundVolume,
      value: value.clamp(0.5, 1.0),
    );
  }

  Future<void> play({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastPlayedAt != null &&
        now.difference(_lastPlayedAt!) < const Duration(milliseconds: 900)) {
      return;
    }
    _lastPlayedAt = now;

    await Future.wait([
      if (isEnabled) _playSound(),
      if (vibrationEnabled) _vibrate(),
    ]);
  }

  Future<void> _playSound() async {
    try {
      await _player.stop();
      await _player.setVolume(1.0);
      await _player.play(
        AssetSource('sounds/notification.wav'),
        volume: volume,
      );
    } catch (_) {}
  }

  Future<void> _vibrate() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        final hasAmplitude = await Vibration.hasAmplitudeControl();
        if (hasAmplitude == true) {
          await Vibration.vibrate(
            pattern: [0, 220, 90, 280, 90, 320],
            intensities: [0, 255, 0, 255, 0, 255],
          );
        } else {
          await Vibration.vibrate(
            pattern: [0, 220, 90, 280, 90, 320],
          );
        }
        return;
      }
    } catch (_) {}

    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
