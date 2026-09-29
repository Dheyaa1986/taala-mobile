import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class UsageGuidesPrefs {
  const UsageGuidesPrefs._();

  static Future<int> readRevision(SharedPref prefs) async {
    final value = prefs.get(key: PrefsKeys.usageGuidesRevision);
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Future<void> saveRevision(SharedPref prefs, int revision) async {
    await prefs.set(key: PrefsKeys.usageGuidesRevision, value: revision);
  }
}
