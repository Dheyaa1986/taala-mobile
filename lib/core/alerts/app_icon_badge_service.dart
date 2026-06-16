import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';

class AppIconBadgeService {
  Future<void> updateCount(int count) async {
    await applyCount(count);
  }

  static Future<void> applyCount(int count) async {
    final safeCount = count < 0 ? 0 : count;

    try {
      if (await AppBadgePlus.isSupported()) {
        await AppBadgePlus.updateBadge(safeCount);
      }
    } catch (error) {
      debugPrint('App icon badge update failed: $error');
    }
  }
}
