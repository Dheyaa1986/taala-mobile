import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_config/app_icons.dart';
import '../../core/app_config/app_strings.dart';
import '../../core/widgets/svg_image/svg_image_widget.dart';
import '../theme/taala_tokens.dart';
import '../tokens/taala_shadows.dart';

class TaalaBottomNavItem {
  const TaalaBottomNavItem({
    required this.label,
    this.icon,
    this.activeIcon,
    this.materialIcon,
  }) : assert(icon != null || materialIcon != null);

  final String label;
  final String? icon;
  final String? activeIcon;
  final IconData? materialIcon;
}

class TaalaBottomNavBar extends StatelessWidget {
  const TaalaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TaalaBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.borderSubtle)),
        boxShadow: TaalaShadows.soft(brightness),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = currentIndex == index;
              return Expanded(
                child: _NavItem(
                  item: item,
                  selected: selected,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final TaalaBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final color = selected ? tokens.primary : tokens.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: tokens.primary.withValues(alpha: 0.12),
        highlightColor: tokens.primary.withValues(alpha: 0.08),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 52.h, minWidth: 48.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: selected ? tokens.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.materialIcon != null)
                  Icon(item.materialIcon, size: 22.r, color: color)
                else
                  SvgImageWidget(
                    image: selected && item.activeIcon != null
                        ? item.activeIcon!
                        : item.icon!,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    width: 22.r,
                    height: 22.r,
                  ),
                SizedBox(height: 3.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TaalaBottomNavItem homeNavItem() => TaalaBottomNavItem(
      label: AppStrings.home.tr(),
      icon: AppIcons.home,
      activeIcon: AppIcons.homeActive,
    );

TaalaBottomNavItem menuNavItem() => TaalaBottomNavItem(
      label: AppStrings.menu.tr(),
      icon: AppIcons.menu,
    );

TaalaBottomNavItem servicesNavItem() => TaalaBottomNavItem(
      label: AppStrings.services.tr(),
      materialIcon: Icons.grid_view_rounded,
    );

TaalaBottomNavItem providersNavItem() => TaalaBottomNavItem(
      label: AppStrings.serviceProviders.tr(),
      icon: AppIcons.provider,
    );

TaalaBottomNavItem portfolioNavItem() => TaalaBottomNavItem(
      label: AppStrings.portfolio.tr(),
      materialIcon: Icons.photo_library_outlined,
    );
