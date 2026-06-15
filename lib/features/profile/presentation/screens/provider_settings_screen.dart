import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/presentation/widgets/app_alert_sound_settings.dart';
import 'package:taal/features/profile/client/presentation/widgets/rate_app_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_tile.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_sheet.dart';

class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.menu.tr(),
        centerTitle: true,
      ),
      body: ListView(
        padding: REdgeInsets.all(16),
        children: [
          const AppAlertSoundSettings(),
          16.height,
          SettingsTile(
            title: AppStrings.mySupportTickets,
            onTap: () => context.pushNamed(Routes.supportTickets),
          ),
          16.height,
          SettingsTile(
            title: AppStrings.submitSupportTicket,
            onTap: () => showSupportTicketSheet(context),
          ),
          16.height,
          SettingsTile(
            title: AppStrings.rateApp,
            onTap: () => showRateAppSheet(context),
          ),
          _divider(),
          _logoutTile(context),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        color: AppColors.lightGreyDividerColor,
        height: 36.h,
      );

  Widget _logoutTile(BuildContext context) => GestureDetector(
        onTap: () => getIt<DioService>().logout(),
        child: Card(
          elevation: 3,
          shadowColor: const Color(0x269A9A9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: const BorderSide(color: AppColors.brandBorder),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgImageWidget(
                  image: AppIcons.login,
                  width: 24.w,
                  height: 24.h,
                ),
                8.width,
                Text(
                  AppStrings.logout.tr(),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.redColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
}
