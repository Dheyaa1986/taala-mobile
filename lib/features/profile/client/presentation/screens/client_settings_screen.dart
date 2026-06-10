import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/locale_helper.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/client/presentation/widgets/change_password_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/edit_profile_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/lang_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/rate_app_sheet.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_sheet.dart';
import '../widgets/settings_tile.dart';

class ClientSettingsScreen extends StatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return Scaffold(
      appBar: CustomAppBar.langAppBar(
        title: AppStrings.settings.tr(),
        centerTitle: true,
        showProfileIcon: true,
      ),
      body: ListView(
        padding: REdgeInsets.all(16.0),
        children: [
          _profileTile(context: context),
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
            onTap: () {
              showChangePasswordSheet(context);
            },
          ),
          16.height,
          SettingsTile(
            title: AppStrings.rateApp,
            onTap: () {
              showRateAppSheet(context);
            },
          ),
          16.height,
          SettingsTile(
            title: AppStrings.submitSupportTicket,
            onTap: () => showSupportTicketSheet(context),
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
        onTap: () async {
          await getIt<DioService>().logout();
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
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final name = state is ProfileLoaded ? state.profile.name : '...';
        final email = state is ProfileLoaded ? state.profile.email : '...';
        final imageUrl =
            state is ProfileLoaded ? state.profile.imageLink : null;

        return GestureDetector(
          onTap: () {
            if (state is ProfileLoaded) {
              showEditProfileSheet(context, profile: state.profile);
            }
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
              leading: imageUrl != null && imageUrl.isNotEmpty
                  ? CustomCachedNetworkImage(
                      radius: 100.r,
                      url: imageUrl,
                      width: 48.w,
                      height: 48.w,
                    )
                  : CircleAvatar(
                      radius: 24.r,
                      child: Text(name.isNotEmpty ? name[0] : '?'),
                    ),
              title: Text(
                name,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              subtitle: Text(
                email,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
