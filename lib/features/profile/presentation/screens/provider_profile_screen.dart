import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taal/features/profile/presentation/cubit/provider_profile_cubit.dart';
import 'package:taal/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:taal/features/profile/presentation/widgets/provider_profile_client_widgets.dart';
import 'package:taal/features/profile/presentation/widgets/service_chip.dart';

import '../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String? id;
  const ProviderProfileScreen({super.key, this.id});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late final ProviderProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProviderProfileCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final isProvider =
        context.read<BottomNavigationCubit>().isProvider ?? false;
    String? currentUserId;

    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    } else {
      await context.read<ProfileCubit>().loadProfile();
      if (!mounted) return;
      final refreshed = context.read<ProfileCubit>().state;
      if (refreshed is ProfileLoaded) {
        currentUserId = refreshed.profile.id;
      }
    }

    await _cubit.load(
      providerId: widget.id,
      currentUserId: currentUserId,
      isProviderAccount: isProvider,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: CustomAppBar.langAppBar(
          title: AppStrings.profileTitle.tr(),
          actions: [
            IconButton(
              icon: const SvgImageWidget(
                image: AppIcons.share,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ProviderProfileCubit, ProviderProfileState>(
          builder: (context, state) {
            if (state is ProviderProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProviderProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    16.height,
                    CustomButton.filled(
                      onTap: _loadProfile,
                      text: AppStrings.retry.tr(),
                    ),
                  ],
                ),
              );
            }

            if (state is! ProviderProfileLoaded &&
                state is! ProviderProfileRefreshing) {
              return const SizedBox.shrink();
            }

            final provider = state is ProviderProfileLoaded
                ? state.provider
                : (state as ProviderProfileRefreshing).provider;
            final showProviderTools = state is ProviderProfileLoaded
                ? state.showProviderTools
                : (state as ProviderProfileRefreshing).showProviderTools;
            final showClientView = !showProviderTools;
            final services = provider.services;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
              child: CustomScrollView(
                slivers: [
                  SliverList.list(
                    children: [
                      20.height,
                      Align(
                        child: ProfileAvatar(
                          isActive: showProviderTools,
                          url: provider.image ?? '',
                        ),
                      ),
                      20.height,
                      Text(
                        provider.name ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      8.height,
                      if (showClientView)
                        ProviderProfileClientWidgets(provider: provider),
                      if (showProviderTools) ...[
                        if (services.isNotEmpty) ...[
                          16.height,
                          SizedBox(
                            height: 32.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) => ServiceChip(
                                service: services[index],
                              ),
                              separatorBuilder: (_, __) => 10.width,
                              itemCount: services.length,
                            ),
                          ),
                        ],
                        24.height,
                        Align(
                          child: CustomButton.filled(
                            onTap: () => context.pushNamed(Routes.editProfile),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            radius: const Radius.circular(12).r,
                            width: 161.w,
                            text: AppStrings.editProfile.tr(),
                          ),
                        ),
                        32.height,
                        GestureDetector(
                          onTap: () => getIt<DioService>().logout(),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout, color: Colors.red),
                                8.width,
                                Text(
                                  AppStrings.logout.tr(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        16.height,
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
