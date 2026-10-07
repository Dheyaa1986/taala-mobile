import 'dart:io';

import 'package:local_auth/local_auth.dart';

import '../app_config/prefs_keys.dart';
import 'secure_local_storage.dart';

class BiometricAuth {
  BiometricAuth._();

  static final LocalAuthentication _auth = LocalAuthentication();
  static bool _armAfterPasswordLogin = false;

  static Future<bool> isEnabled() async {
    return (await SecureLocalStorage.read(PrefsKeys.biometricUnlockEnabled)) ==
        '1';
  }

  static Future<bool> wasOfferHandled() async {
    return (await SecureLocalStorage.read(
          PrefsKeys.biometricUnlockOfferHandled,
        )) ==
        '1';
  }

  static Future<void> enable() async {
    await SecureLocalStorage.write(PrefsKeys.biometricUnlockEnabled, '1');
    await SecureLocalStorage.write(PrefsKeys.biometricUnlockOfferHandled, '1');
  }

  static Future<void> markOfferHandled() async {
    await SecureLocalStorage.write(PrefsKeys.biometricUnlockOfferHandled, '1');
  }

  static Future<void> disable() async {
    await SecureLocalStorage.delete(PrefsKeys.biometricUnlockEnabled);
  }

  static void armAfterPasswordLogin() {
    _armAfterPasswordLogin = true;
  }

  static bool consumeArm() {
    final armed = _armAfterPasswordLogin;
    _armAfterPasswordLogin = false;
    return armed;
  }

  static Future<bool> canUseDeviceKey() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      return await _auth.isDeviceSupported() ||
          await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
