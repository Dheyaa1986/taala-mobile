import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class AppIconBadgeService {
  Future<void> updateCount(int count) async {
    final safeCount = count < 0 ? 0 : count;

    try {
      await getIt<SharedPref>().set(
        key: PrefsKeys.appIconBadgeCount,
        value: safeCount,
      );
    } catch (error) {
      debugPrint('App icon badge cache failed: $error');
    }

    try {
      final supported = await AppBadgePlus.isSupported();
      if (!supported) return;
      await AppBadgePlus.updateBadge(safeCount);
    } catch (error) {
      debugPrint('App icon badge update failed: $error');
    }
  }

  Future<void> incrementCachedCount() async {
    final cached = getIt<SharedPref>().get(key: PrefsKeys.appIconBadgeCount);
    final current = cached is int
        ? cached
        : cached is num
            ? cached.toInt()
            : int.tryParse(cached?.toString() ?? '') ?? 0;
    await updateCount(current + 1);
  }
}
