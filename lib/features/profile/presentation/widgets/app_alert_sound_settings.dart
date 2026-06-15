import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/alerts/app_alert_sound_service.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';

class AppAlertSoundSettings extends StatefulWidget {
  const AppAlertSoundSettings({super.key});

  @override
  State<AppAlertSoundSettings> createState() => _AppAlertSoundSettingsState();
}

class _AppAlertSoundSettingsState extends State<AppAlertSoundSettings> {
  final _soundService = getIt<AppAlertSoundService>();
  late bool _enabled;
  late bool _vibrationEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _enabled = _soundService.isEnabled;
    _vibrationEnabled = _soundService.vibrationEnabled;
    _volume = _soundService.volume;
  }

  Future<void> _toggleEnabled(bool value) async {
    await _soundService.setEnabled(value);
    if (!mounted) return;
    setState(() => _enabled = value);
    if (value || _vibrationEnabled) {
      await _soundService.play(force: true);
    }
  }

  Future<void> _toggleVibration(bool value) async {
    await _soundService.setVibrationEnabled(value);
    if (!mounted) return;
    setState(() => _vibrationEnabled = value);
    if (value) {
      await _soundService.play(force: true);
    }
  }

  Future<void> _updateVolume(double value) async {
    await _soundService.setVolume(value);
    if (!mounted) return;
    setState(() => _volume = value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: AppColors.brandBorder),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: REdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appAlertSound.tr(),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      4.height,
                      Text(
                        AppStrings.appAlertSoundSubtitle.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.commentColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enabled,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: _toggleEnabled,
                ),
              ],
            ),
            12.height,
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.appAlertVibration.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightMainText,
                    ),
                  ),
                ),
                Switch(
                  value: _vibrationEnabled,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: _toggleVibration,
                ),
              ],
            ),
            if (_enabled) ...[
              16.height,
              Text(
                AppStrings.appAlertSoundVolume.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightMainText,
                ),
              ),
              Slider(
                value: _volume,
                min: 0.5,
                max: 1,
                divisions: 5,
                activeColor: AppColors.primaryColor,
                onChanged: _updateVolume,
                onChangeEnd: (_) => _soundService.play(force: true),
              ),
            ],
            8.height,
            CustomButton.outlined(
              text: AppStrings.testAlertSound.tr(),
              onTap: () => _soundService.play(force: true),
            ),
          ],
        ),
      ),
    );
  }
}
