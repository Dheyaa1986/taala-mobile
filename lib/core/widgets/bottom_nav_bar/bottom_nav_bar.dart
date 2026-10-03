import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/guest/guest_welcome_banner.dart';
import '../../../core/helpers/guest_session_helper.dart';
import '../../../design_system/components/taala_bottom_nav.dart';
import '../../widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../dialog/exit_app_dialog.dart';
import '../../../features/usage_guides/presentation/widgets/usage_guides_prompt.dart';

class BottomNavBar extends StatefulWidget {
  final StatefulNavigationShell shell;
  const BottomNavBar({super.key, required this.shell});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static const int _menuBranchIndex = 3;
  bool _usagePromptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleUsageGuidesPrompt());
  }

  void _scheduleUsageGuidesPrompt() {
    if (_usagePromptScheduled || !mounted) return;
    _usagePromptScheduled = true;
    maybeShowUsageGuidesPrompt(context);
  }

  bool get _isProvider => context.read<BottomNavigationCubit>().isProvider;

  int _branchIndexForNav(int navIndex) {
    if (_isProvider) {
      return switch (navIndex) {
        0 => 0,
        1 => 2,
        2 => _menuBranchIndex,
        _ => 0,
      };
    }
    return navIndex;
  }

  int _navIndexForBranch(int branchIndex) {
    if (_isProvider) {
      return switch (branchIndex) {
        0 => 0,
        2 => 1,
        _menuBranchIndex => 2,
        _ => 0,
      };
    }
    return branchIndex;
  }

  void _onItemTapped(int navIndex) {
    final branchIndex = _branchIndexForNav(navIndex);
    if (branchIndex == widget.shell.currentIndex && branchIndex == 0) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.lightImpact();
    widget.shell.goBranch(
      branchIndex,
      initialLocation: branchIndex == _menuBranchIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = _navIndexForBranch(widget.shell.currentIndex);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.shell.currentIndex != 0) {
          widget.shell.goBranch(0);
          return;
        }
        if (await GuestSessionHelper.isGuestBrowsing()) {
          if (!context.mounted) return;
          await GuestSessionHelper.returnToStart(context);
          return;
        }
        if (!context.mounted) return;
        final bool shouldPop = await showExitAppDialog(context);
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: null,
        body: Column(
          children: [
            const GuestWelcomeBanner(),
            Expanded(child: widget.shell),
          ],
        ),
        bottomNavigationBar: Localizations.override(
          context: context,
          locale: context.locale,
          child: TaalaBottomNavBar(
            currentIndex: navIndex,
            onTap: _onItemTapped,
            items: _navItems,
          ),
        ),
      ),
    );
  }

  List<TaalaBottomNavItem> get _navItems {
    if (_isProvider) {
      return [
        homeNavItem(),
        portfolioNavItem(),
        menuNavItem(),
      ];
    }
    return [
      homeNavItem(),
      servicesNavItem(),
      providersNavItem(),
      menuNavItem(),
    ];
  }
}
