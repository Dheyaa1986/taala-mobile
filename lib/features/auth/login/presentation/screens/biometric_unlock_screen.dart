import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/biometric_auth.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/auth/login/presentation/widgets/device_key_button.dart';

class BiometricUnlockScreen extends StatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  State<BiometricUnlockScreen> createState() => _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends State<BiometricUnlockScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unlock();
    });
  }

  void _openPasswordLogin() {
    context.goNamed(Routes.login);
  }

  Future<void> _unlock() async {
    if (_busy) return;
    if (!await BiometricAuth.canUseDeviceKey()) {
      if (!mounted) return;
      AppMessages.showError(context, AppStrings.biometricUnavailable.tr());
      return;
    }

    setState(() => _busy = true);
    final ok = await BiometricAuth.authenticate(
      reason: AppStrings.biometricUnlockReason.tr(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;

    final session = await AuthSessionHelper.hasActiveSession();
    if (!mounted) return;
    if (!session) {
      await AuthSessionHelper.clearSession();
      if (!mounted) return;
      AppMessages.showError(context, AppStrings.biometricSessionExpired.tr());
      context.goNamed(Routes.login);
      return;
    }

    await AuthSessionHelper.openAuthenticatedApp(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _openPasswordLogin();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                  tooltip: AppStrings.biometricUsePassword.tr(),
                  onPressed: _openPasswordLogin,
                  icon: Icon(Icons.close, color: tokens.textPrimary),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/taal.png', width: 180),
                      28.height,
                      Text(
                        AppStrings.biometricUnlockTitle.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                      8.height,
                      Text(
                        AppStrings.biometricUnlockSubtitle.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                      ),
                      28.height,
                      DeviceKeyButton(
                        size: 72,
                        onPressed: _busy ? null : _unlock,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
