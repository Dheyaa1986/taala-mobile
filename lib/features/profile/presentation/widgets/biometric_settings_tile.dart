import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/biometric_auth.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_card_shell.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_grouped_card.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({super.key});

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  bool _supported = false;
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supported = await BiometricAuth.canUseDeviceKey();
    final enabled = supported && await BiometricAuth.isEnabled();
    if (!mounted) return;
    setState(() {
      _supported = supported;
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggle(bool value) async {
    if (!_supported) {
      AppMessages.showError(context, AppStrings.biometricUnavailable.tr());
      return;
    }
    if (!value) {
      await BiometricAuth.disable();
      if (mounted) setState(() => _enabled = false);
      return;
    }
    final ok = await BiometricAuth.authenticate(
      reason: AppStrings.biometricUnlockReason.tr(),
    );
    if (!ok) return;
    await BiometricAuth.enable();
    if (mounted) setState(() => _enabled = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_supported) return const SizedBox.shrink();
    final tokens = TaalaTokens.of(context);
    return SettingsCardShell(
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SettingsIconBadge(
              icon: Icons.fingerprint,
              iconColor: tokens.primary,
              backgroundColor: tokens.primary.withValues(alpha: 0.12),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                AppStrings.biometricSettingsTitle.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: tokens.textPrimary,
                    ),
              ),
            ),
            Switch.adaptive(
              value: _enabled,
              onChanged: _toggle,
            ),
          ],
        ),
      ),
    );
  }
}
