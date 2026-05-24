import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/extensions.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/client/presentation/widgets/change_password_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/edit_profile_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/lang_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/rate_app_sheet.dart';
import '../widgets/settings_tile.dart';

class ClientSettingsScreen extends StatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.langAppBar(
        title: AppStrings.settings.tr(),
        centerTitle: true,
      ),
      body: ListView(
        padding: REdgeInsets.all(16.0),
        children: [
          _profileTile(context: context),
          _divider(),
          SettingsTile(
            title: AppStrings.language.tr(),
            onTap: () {
              return showLangSheet(context).then(
                (value) {
                  if (value != null && value is AppLang) {

                    setState(() {
                      context.setLocale(Locale(value.code));
                    });
                  }
                },
              );
            },
          ),
          16.height,
          SettingsTile(
            title: AppStrings.changePassword.tr(),
            onTap: () {
              showChangePasswordSheet(context);
            },
          ),
          16.height,
          SettingsTile(
            title: AppStrings.rateApp.tr(),
            onTap: () {
              showRateAppSheet(context);
            },
          ),
          _divider(),
          _logoutTile(context),
        ],
      ),
    );
  }

  _divider() => Divider(
        color: AppColors.lightGreyDividerColor,
        height: 36.h,
      );

  _logoutTile(BuildContext context) => GestureDetector(
        onTap: () {
          context.pushNamedAndRemoveUntil(
            Routes.login,
            predicate: (route) => false,
          );
        },
        child: Card(
          elevation: 3,
          shadowColor: const Color(0x269A9A9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: const BorderSide(
              color: AppColors.borderColorMain,
            ),
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

  _profileTile({required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        showEditProfileSheet(context);
      },
      child: Card(
        elevation: 3,
        shadowColor: const Color(0x269A9A9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(
            color: AppColors.borderColorMain,
          ),
        ),
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: REdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.greyText,
            size: 10.r,
          ),
          leading: CustomCachedNetworkImage(
            radius: 100.r,
            url:
                "https://media.istockphoto.com/id/1682296067/photo/happy-studio-portrait-or-professional-man-real-estate-agent-or-asian-businessman-smile-for.jpg?s=612x612&w=0&k=20&c=9zbG2-9fl741fbTWw5fNgcEEe4ll-JegrGlQQ6m54rg=",
            width: 48.w,
            height: 48.w,
          ),
          title: Text('John Doe',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  )),
          subtitle: Text('client@gmail.com',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  )),
        ),
      ),
    );
  }
}
