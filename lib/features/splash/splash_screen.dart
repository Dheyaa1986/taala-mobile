import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';

import '../../core/app_config/prefs_keys.dart';
import '../../core/di/service_locator.dart';
import '../../core/helpers/auth_session_helper.dart';
import '../../core/helpers/secure_local_storage.dart';
import '../../core/helpers/shared_pref_local_storage.dart';
import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.isProvider});
  final bool? isProvider;

  Future<void> _checkAuthAndNavigate(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final hadStoredToken =
        (await SecureLocalStorage.read(PrefsKeys.token))?.isNotEmpty == true;

    if (await AuthSessionHelper.hasActiveSession()) {
      final isProviderAccount =
          getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
      context.read<BottomNavigationCubit>().isProvider = isProviderAccount;
      context.goNamed(Routes.home);
    } else {
      if (hadStoredToken) {
        await AuthSessionHelper.clearSession();
      }
      final isProvider =
          getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
      context.goNamed(Routes.login, extra: isProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAuthAndNavigate(context),
      builder: (context, snapshot) => Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Image.asset(
            'assets/taal.png',
            width: 250,
          ),
        ),
      ),
    );
  }
}
