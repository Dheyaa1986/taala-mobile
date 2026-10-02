import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';

class GuestActionGuard {
  const GuestActionGuard._();

  /// Returns `true` when the action may proceed (logged-in user).
  static Future<bool> ensureRegistered(BuildContext context) async {
    if (await AuthSessionHelper.hasActiveSession()) return true;

    final isGuest = await GuestSessionHelper.isGuestBrowsing();
    if (!isGuest) {
      if (context.mounted) {
        context.pushNamed(Routes.login);
      }
      return false;
    }

    if (!context.mounted) return false;

    final goRegister = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.guestRegistrationRequiredTitle.tr()),
        content: Text(AppStrings.guestRegistrationRequiredMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.guestContinueBrowsing.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.guestGoToRegister.tr()),
          ),
        ],
      ),
    );

    if (goRegister == true && context.mounted) {
      context.pushNamed(Routes.register, extra: true);
    }
    return false;
  }
}
