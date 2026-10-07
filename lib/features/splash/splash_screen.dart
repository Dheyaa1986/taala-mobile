import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/config/themes/theme.dart';
import 'package:taal/core/app_config/app_urls.dart';

import 'package:taal/core/widgets/svg_image/lang_popup.dart';

import '../../core/app_config/prefs_keys.dart';
import '../../core/helpers/auth_session_helper.dart';
import '../../core/helpers/biometric_auth.dart';
import '../../core/helpers/guest_session_helper.dart';
import '../../core/helpers/secure_local_storage.dart';
import '../../core/updates/app_update_prompt.dart';
import '../../core/updates/force_update_screen.dart';
import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.isProvider});
  final bool? isProvider;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _forceUpdateRequired = false;
  bool _startupStarted = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _startupStarted) return;
      _startupStarted = true;
      unawaited(_checkAuthAndNavigate(context));
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate(BuildContext context) async {
    final gateResult = await handleAppUpdateCheck(presentBlockingUi: false);
    if (gateResult == AppUpdateGateResult.blocked) {
      if (mounted) {
        setState(() => _forceUpdateRequired = true);
      }
      return;
    }
    if (!context.mounted) return;

    final hasSession = await AuthSessionHelper.hasActiveSession();
    if (!hasSession) {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!context.mounted) return;

    final hadStoredToken =
        (await SecureLocalStorage.read(PrefsKeys.token))?.isNotEmpty == true;

    if (await AuthSessionHelper.hasActiveSession()) {
      if (await BiometricAuth.isEnabled() &&
          await BiometricAuth.canUseDeviceKey()) {
        if (!context.mounted) return;
        context.goNamed(Routes.biometricUnlock);
        return;
      }
      if (!context.mounted) return;
      await AuthSessionHelper.openAuthenticatedApp(context);
    } else {
      if (hadStoredToken) {
        await AuthSessionHelper.clearSession();
      }
      if (!context.mounted) return;
      if (await GuestSessionHelper.isGuestBrowsing()) {
        if (!context.mounted) return;
        context.read<BottomNavigationCubit>().isProvider = false;
        context.goNamed(Routes.home);
      } else {
        context.goNamed(Routes.guestMap);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_forceUpdateRequired) {
      return const ForceUpdateScreen();
    }

    final themeLogo = TariqyAppTheme.activeTheme?.logoUrl;
    final splashLogo = themeLogo != null && themeLogo.isNotEmpty
        ? (themeLogo.startsWith('http')
            ? themeLogo
            : AppUrls.imageLink(themeLogo))
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: splashLogo != null
                  ? Image.network(
                      splashLogo,
                      width: 220,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/taal.png',
                        width: 220,
                      ),
                    )
                  : Image.asset(
                      'assets/taal.png',
                      width: 220,
                    ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: LangPopup(),
            ),
          ),
        ],
      ),
    );
  }
}
