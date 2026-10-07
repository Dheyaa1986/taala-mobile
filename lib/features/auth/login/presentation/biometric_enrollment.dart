import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/biometric_auth.dart';

class BiometricEnrollment {
  const BiometricEnrollment._();

  static Future<void> handleAfterPasswordLogin(BuildContext context) async {
    if (!await BiometricAuth.canUseDeviceKey()) {
      BiometricAuth.consumeArm();
      return;
    }
    if (await BiometricAuth.isEnabled()) {
      BiometricAuth.consumeArm();
      return;
    }
    if (!context.mounted) return;

    final armed = BiometricAuth.consumeArm();
    var accepted = armed;
    if (!armed) {
      if (await BiometricAuth.wasOfferHandled()) return;
      if (!context.mounted) return;
      accepted = await _askToEnable(
        context,
        body: AppStrings.biometricEnableBody.tr(),
      );
      if (!accepted) {
        await BiometricAuth.markOfferHandled();
        return;
      }
    }

    if (!context.mounted) return;
    final ok = await BiometricAuth.authenticate(
      reason: AppStrings.biometricUnlockReason.tr(),
    );
    if (ok) {
      await BiometricAuth.enable();
    }
  }

  static Future<bool> askToArm(BuildContext context) async {
    return _askToEnable(
      context,
      body: AppStrings.biometricArmHint.tr(),
    );
  }

  static Future<bool> _askToEnable(
    BuildContext context, {
    required String body,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.biometricEnableTitle.tr()),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.biometricNotNow.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.biometricEnableAction.tr()),
          ),
        ],
      ),
    );
    return accepted ?? false;
  }
}
