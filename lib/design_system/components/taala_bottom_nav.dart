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
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: selected ? tokens.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.materialIcon != null)
                Icon(item.materialIcon, size: 24.r, color: color)
              else
                SvgImageWidget(
                  image: selected && item.activeIcon != null
                      ? item.activeIcon!
                      : item.icon!,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: 24.r,
                  height: 24.r,
                ),
              SizedBox(height: 4.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
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

TaalaBottomNavItem providersNavItem() => TaalaBottomNavItem(
      label: AppStrings.serviceProviders.tr(),
      icon: AppIcons.provider,
    );

TaalaBottomNavItem portfolioNavItem() => TaalaBottomNavItem(
      label: AppStrings.portfolio.tr(),
      materialIcon: Icons.photo_library_outlined,
    );
