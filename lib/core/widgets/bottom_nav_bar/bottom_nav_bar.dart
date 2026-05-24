import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../dialog/exit_app_dialog.dart';
import '../svg_image/svg_image_widget.dart';
import 'cubit/bottom_navigation_cubit.dart';

class BottomNavBar extends StatefulWidget {
  final StatefulNavigationShell shell;
  const BottomNavBar({super.key, required this.shell});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late BottomNavigationCubit _bottomNavigationCubit;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _bottomNavigationCubit = context.read<BottomNavigationCubit>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onItemTapped(int index) {
    if (index == widget.shell.currentIndex && index == 0) {
      // Already on home, trigger scroll to top
      log("Triggering scroll to top on home screen");

      HapticFeedback.lightImpact();
      return;
    }
    log("Navigating to index: $index");
    HapticFeedback.lightImpact();
    widget.shell.goBranch(index);
  }

  void _goToHomeScreen() {
    log("Navigating to home");
    _onItemTapped(0);
  }

  @override
  Widget build(BuildContext context) {
    final isBaseRoute = widget.shell.currentIndex == 0;

    // Control app bar visibility with animation
    if (isBaseRoute) {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    } else {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        log("Pop invoked: didPop=$didPop, result=$result");
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.lightBGColor,
            // borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.lightSecMainText.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: SizedBox(
            height: 80.h + MediaQuery.of(context).padding.bottom,
            // padding: REdgeInsets.symmetric(horizontal: 16.w),
            child: Localizations.override(
              context: context,
              locale: context.locale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildNavItem(
                    item: _navItems[index],
                    index: index,
                    isSelected: widget.shell.currentIndex == index,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavigationBarItem item,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        // Scale down slightly on press
        setState(() {});
      },
      onTapUp: (_) {
        _onItemTapped(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 89.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background highlight
            AnimatedOpacity(
              opacity: isSelected ? 0.15 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.15),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: isSelected ? 89.w : 0),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutCubicEmphasized,
                  builder: (context, value, child) {
                    return Container(
                      width: value,
                      height: 2.h,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withOpacity(0.7),
                                  AppColors.primaryColor,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    );
                  },
                ),

                SizedBox(
                    height: 16.h + MediaQuery.of(context).padding.bottom / 2),
                // isSelected ? 0.height : 2.height,
                // Icon with bounce animation
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.bounceOut,
                  child: item.icon,
                ),
                4.height,
                // Text with fade, slide, and scale animation
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: AnimatedSlide(
                    offset: Offset.zero,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Text(
                        item.label!,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryColor : null,
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Gradient indicator bar
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> get _navItems => [
        navItem(
          title: AppStrings.home.tr(),
          icon: icon(AppIcons.home, 0, AppIcons.homeActive),
          index: 0,
        ),
        navItem(
          title: AppStrings.rating.tr(),
          icon: icon(AppIcons.star, 1),
          index: 1,
        ),
        navItem(
          title: AppStrings.menu.tr(),
          icon: icon(AppIcons.menu, 2),
          index: 2,
        ),
      ];

  Widget icon(String icon, int index, [String? activeIcon]) {
    final isSelected = widget.shell.currentIndex == index;
    return SvgImageWidget(
      image: isSelected && activeIcon != null ? activeIcon : icon,
      colorFilter: isSelected && activeIcon == null
          ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
          : null,
      width: 24.r,
      height: 24.r,
    );
  }

  BottomNavigationBarItem navItem({
    required String title,
    required Widget icon,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: icon,
      label: title,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
