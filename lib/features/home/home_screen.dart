import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/home/provider/presentation/screens/provider_view.dart';

import '../../core/helpers/auth_session_helper.dart';
import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'client/presentation/screens/client_home_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? _isProvider;

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    final isProvider = await AuthSessionHelper.isProviderSession();
    if (!mounted) return;
    context.read<BottomNavigationCubit>().isProvider = isProvider;
    setState(() => _isProvider = isProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_isProvider == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: _isProvider!
            ? const LocationsScreen()
            : const ClientHomeView(),
      ),
    );
  }
}
