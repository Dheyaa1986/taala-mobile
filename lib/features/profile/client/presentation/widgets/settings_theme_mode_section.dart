import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/theme/app_theme_mode_cubit.dart';
import 'package:taal/core/theme/app_theme_preference.dart';
import 'package:taal/design_system/components/taala_chip.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_card_shell.dart';

class SettingsThemeModeSection extends StatelessWidget {
  const SettingsThemeModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return BlocBuilder<AppThemeModeCubit, AppThemePreference>(
      bloc: getIt<AppThemeModeCubit>(),
      builder: (context, selected) {
        return SettingsCardShell(
          padding: REdgeInsets.all(16),
          borderRadius: tokens.cardRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.dark_mode_outlined,
                      color: const Color(0xFF5C6BC0),
                      size: 20.r,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Text(
                      AppStrings.appearance.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
              6.height,
              Text(
                AppStrings.appearanceSubtitle.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                      height: 1.4,
                    ),
              ),
              14.height,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  TaalaChip(
                    label: AppStrings.themeSystem.tr(),
                    selected: selected == AppThemePreference.system,
                    onTap: () => getIt<AppThemeModeCubit>().setPreference(
                      AppThemePreference.system,
                    ),
                  ),
                  TaalaChip(
                    label: AppStrings.themeLight.tr(),
                    selected: selected == AppThemePreference.light,
                    onTap: () => getIt<AppThemeModeCubit>().setPreference(
                      AppThemePreference.light,
                    ),
                  ),
                  TaalaChip(
                    label: AppStrings.themeDark.tr(),
                    selected: selected == AppThemePreference.dark,
                    onTap: () => getIt<AppThemeModeCubit>().setPreference(
                      AppThemePreference.dark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

