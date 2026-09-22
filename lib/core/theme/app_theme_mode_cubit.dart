import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/theme/app_theme_preference.dart';

class AppThemeModeCubit extends Cubit<AppThemePreference> {
  AppThemeModeCubit(this._prefs) : super(AppThemePreference.system) {
    _load();
  }

  final SharedPref _prefs;

  void _load() {
    final stored = _prefs.get(key: PrefsKeys.appThemeMode) as String?;
    emit(AppThemePreference.fromStorage(stored));
  }

  Future<void> setPreference(AppThemePreference preference) async {
    if (preference == state) return;
    await _prefs.set(key: PrefsKeys.appThemeMode, value: preference.name);
    emit(preference);
  }
}
