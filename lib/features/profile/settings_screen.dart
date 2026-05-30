import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/profile/client/presentation/screens/client_settings_screen.dart';
import 'package:taal/features/profile/presentation/screens/provider_settings_screen.dart';

import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class BaseSettingsScreen extends StatefulWidget {
  const BaseSettingsScreen({super.key});

  @override
  State<BaseSettingsScreen> createState() => _BaseSettingsScreenState();
}

class _BaseSettingsScreenState extends State<BaseSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _syncAccountType();
  }

  void _syncAccountType() {
    final isProvider =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
    context.read<BottomNavigationCubit>().isProvider = isProvider;
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = context.watch<BottomNavigationCubit>().isProvider;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: isProvider
            ? const ProviderSettingsScreen()
            : const ClientSettingsScreen(),
      ),
    );
  }
}
