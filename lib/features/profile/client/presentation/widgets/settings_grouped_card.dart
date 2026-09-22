import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../design_system/theme/taala_tokens.dart';
import 'settings_card_shell.dart';

class SettingsGroupItem {
  const SettingsGroupItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final Color? titleColor;
}

class SettingsGroupedCard extends StatelessWidget {
  const SettingsGroupedCard({
    super.key,
    required this.items,
  });

  final List<SettingsGroupItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return SettingsCardShell(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
                color: tokens.borderSubtle,
              ),
            _GroupedRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _GroupedRow extends StatelessWidget {
  const _GroupedRow({required this.item});

  final SettingsGroupItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _SettingsIconBadge(
              icon: item.icon,
              iconColor: item.iconColor,
              backgroundColor: item.iconBackgroundColor,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item.title.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: item.titleColor ?? tokens.textPrimary,
                    ),
              ),
            ),
            Icon(
              Directionality.of(context) == ui.TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color: tokens.textSecondary.withValues(alpha: 0.45),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsIconBadge extends StatelessWidget {
  const SettingsIconBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return _SettingsIconBadge(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      size: size,
      iconSize: iconSize,
    );
  }
}

class _SettingsIconBadge extends StatelessWidget {
  const _SettingsIconBadge({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: iconColor, size: iconSize.r),
    );
  }
}
