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
import 'package:taal/core/helpers/locale_helper.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/client/presentation/widgets/change_password_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/lang_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_tile.dart';

class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return Scaffold(
      appBar: CustomAppBar.langAppBar(
        title: AppStrings.settings.tr(),
        centerTitle: true,
      ),
      body: ListView(
        padding: REdgeInsets.all(16.0),
        children: [
          _profileTile(context),
          _divider(),
          SettingsTile(
            title: AppStrings.language,
            onTap: () {
              showLangSheet(context).then((value) async {
                if (value != null && value is AppLang && mounted) {
                  await LocaleHelper.apply(context, value.code);
                  setState(() {});
                }
              });
            },
          ),
          16.height,
          SettingsTile(
            title: AppStrings.changePassword,
            onTap: () => showChangePasswordSheet(context),
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
            side: const BorderSide(color: AppColors.borderColorMain),
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

  Widget _profileTile(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).pushNamed(Routes.editProfile),
      child: Card(
        elevation: 3,
        shadowColor: const Color(0x269A9A9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(color: AppColors.borderColorMain),
        ),
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: REdgeInsets.symmetric(horizontal: 16),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.greyText,
            size: 10.r,
          ),
          leading: CustomCachedNetworkImage(
            radius: 100.r,
            url:
                'https://cdn-icons-png.flaticon.com/512/219/219983.png',
            width: 48.w,
            height: 48.w,
          ),
          title: Text(
            'John Doe',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
          ),
          subtitle: Text(
            'provider@gmail.com',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
