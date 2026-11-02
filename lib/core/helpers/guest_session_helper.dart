import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/subscriptions/presentation/utils/provider_subscription_gate.dart';

class GuestSessionHelper {
  const GuestSessionHelper._();

  static bool suppressAuthRefresh = false;

  static Future<bool> isGuestBrowsing() async {
    if (await AuthSessionHelper.hasActiveSession()) return false;
    return getIt<SharedPref>().get(key: PrefsKeys.isGuestBrowsing) == true;
  }

  static Future<void> startGuestBrowsing() async {
    suppressAuthRefresh = true;
    getIt<AppAlertMonitor>().stop();
    ProviderSubscriptionGate.invalidate();
    await AuthSessionHelper.clearSession();
    await getIt<SharedPref>().set(key: PrefsKeys.isGuestBrowsing, value: true);
    await getIt<SharedPref>().set(
      key: PrefsKeys.isProviderAccount,
      value: false,
    );
    AuthSessionHelper.syncNavigationRole(false);
  }

  static Future<void> clearGuestBrowsing() async {
    suppressAuthRefresh = false;
    await getIt<SharedPref>().set(key: PrefsKeys.isGuestBrowsing, value: false);
  }

  static Future<void> returnToStart(BuildContext context) async {
    await clearGuestBrowsing();
    if (!context.mounted) return;
    context.goNamed(Routes.guestMap);
  }
}
