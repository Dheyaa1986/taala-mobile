import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../../widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../dialog/exit_app_dialog.dart';
import '../svg_image/svg_image_widget.dart';

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

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
        bottomNavigationBar: Material(
          elevation: 8,
          color: backgroundColor,
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: 6.h),
            child: SizedBox(
              height: 64.h,
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
                      primaryColor: primaryColor,
                    ),
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
    required Color primaryColor,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          splashColor: primaryColor.withValues(alpha: 0.12),
          highlightColor: primaryColor.withValues(alpha: 0.08),
          child: SizedBox(
            height: 64.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: isSelected ? 40.w : 0),
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
                                  primaryColor.withValues(alpha: 0.7),
                                  primaryColor,
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
                6.height,
                item.icon,
                4.height,
                Text(
                  item.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? primaryColor : null,
                    fontSize: 11.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> get _navItems {
    final isProvider =
        context.read<BottomNavigationCubit>().isProvider ?? false;
    return [
        navItem(
          title: AppStrings.home.tr(),
          icon: icon(AppIcons.home, 0, AppIcons.homeActive),
          index: 0,
        ),
        navItem(
          title: isProvider
              ? AppStrings.rating.tr()
              : AppStrings.projectsGallery.tr(),
          icon: icon(AppIcons.star, 1),
          index: 1,
        ),
        navItem(
          title: AppStrings.menu.tr(),
          icon: icon(AppIcons.menu, 2),
          index: 2,
        ),
      ];
  }

  Widget icon(String icon, int index, [String? activeIcon]) {
    final isSelected = widget.shell.currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SvgImageWidget(
      image: isSelected && activeIcon != null ? activeIcon : icon,
      colorFilter: isSelected && activeIcon == null
          ? ColorFilter.mode(primaryColor, BlendMode.srcIn)
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
}
