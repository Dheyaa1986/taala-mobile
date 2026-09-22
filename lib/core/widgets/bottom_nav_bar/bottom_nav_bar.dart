import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/taala_bottom_nav.dart';
import '../../widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../dialog/exit_app_dialog.dart';

class BottomNavBar extends StatefulWidget {
  final StatefulNavigationShell shell;
  const BottomNavBar({super.key, required this.shell});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    if (index == widget.shell.currentIndex && index == 0) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.lightImpact();
    widget.shell.goBranch(
      index,
      initialLocation: index == 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && widget.shell.currentIndex != 0) {
          widget.shell.goBranch(0);
        } else if (!didPop && widget.shell.currentIndex == 0) {
          final bool shouldPop = await showExitAppDialog(context);
          if (shouldPop) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: null,
        body: widget.shell,
        bottomNavigationBar: Localizations.override(
          context: context,
          locale: context.locale,
          child: TaalaBottomNavBar(
            currentIndex: widget.shell.currentIndex,
            onTap: _onItemTapped,
            items: _navItems,
          ),
        ),
      ),
    );
  }

  List<TaalaBottomNavItem> get _navItems {
    final isProvider =
        context.read<BottomNavigationCubit>().isProvider ?? false;
    return [
      homeNavItem(),
      isProvider ? portfolioNavItem() : providersNavItem(),
      menuNavItem(),
    ];
  }
}
