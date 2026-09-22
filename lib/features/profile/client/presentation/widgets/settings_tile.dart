import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../design_system/theme/taala_tokens.dart';
import '../../../../../design_system/tokens/taala_shadows.dart';
import 'settings_card_shell.dart';
import 'settings_grouped_card.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.onTap,
    this.titleColor,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return SettingsCardShell(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (icon != null &&
                  iconColor != null &&
                  iconBackgroundColor != null) ...[
                SettingsIconBadge(
                  icon: icon!,
                  iconColor: iconColor!,
                  backgroundColor: iconBackgroundColor!,
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Text(
                  title.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? tokens.textPrimary,
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
      ),
    );
  }
}

class SettingsLogoutTile extends StatelessWidget {
  const SettingsLogoutTile({
    super.key,
    required this.onTap,
    this.icon,
  });

  final VoidCallback onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.error.withValues(alpha: 0.35)),
        boxShadow: TaalaShadows.card(Theme.of(context).brightness),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: 8.w),
                ],
                Text(
                  AppStrings.logout.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: tokens.error,
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
