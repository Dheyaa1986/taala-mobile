import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/profile/client/presentation/screens/client_settings_screen.dart';
import 'package:taal/features/profile/presentation/screens/provider_profile_screen.dart';

import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class BaseSettingsScreen extends StatelessWidget {
  const BaseSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: context.watch<BottomNavigationCubit>().isProvider
            ? const ProviderProfileScreen()
            : const ClientSettingsScreen(),
      ),
    );
  }
}
