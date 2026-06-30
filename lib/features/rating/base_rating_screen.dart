import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/home/client/presentation/screens/client_providers_screen.dart';
import 'package:taal/features/profile/presentation/screens/provider_portfolio_screen.dart';

import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class BaseRatingScreen extends StatelessWidget {
  const BaseRatingScreen({super.key });

  @override
  Widget build(BuildContext context) {
    final isProvider = context.read<BottomNavigationCubit>().isProvider ?? false;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: isProvider
            ? const ProviderPortfolioScreen()
            : const ClientProvidersScreen(),
      ),
    );
  }
}
