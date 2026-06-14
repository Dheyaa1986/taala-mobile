import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/provider_live_location_service.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/add_location_sheet.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taal/features/service_orders/presentation/widgets/provider_service_orders_panel.dart';

import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../widgets/locations_list.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final searchController = TextEditingController();
  final _liveLocationService = getIt<ProviderLiveLocationService>();
  bool _isAvailable = true;
  bool _updatingAvailability = false;

  @override
  void initState() {
    super.initState();
    _syncAvailabilityFromProfile();
  }

  Future<void> _syncAvailabilityFromProfile() async {
    final cubit = getIt<ProfileCubit>();
    if (cubit.state is! ProfileLoaded) {
      await cubit.loadProfile();
    }
    final state = cubit.state;
    if (state is ProfileLoaded) {
      final available = state.profile.providerStatus ?? true;
      if (!mounted) return;
      setState(() => _isAvailable = available);
      if (available) {
        await _liveLocationService.setAvailability(true);
      }
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() {
      _isAvailable = value;
      _updatingAvailability = true;
    });
    await _liveLocationService.setAvailability(value);
    if (mounted) {
      setState(() => _updatingAvailability = false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LocationCubit>(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: CustomAppBar.langAppBar(
            showProfileIcon: true,
            titleFS: 24.sp,
            centerTitle: true,
            title: AppStrings.locations.tr(),
            actions: [
              IconButton(
                tooltip: AppStrings.myServiceOrders.tr(),
                icon: const Icon(Icons.assignment_outlined),
                onPressed: () => context.pushNamed(Routes.serviceOrders),
              ),
            ],
          ),
          body: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Container(
                  padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFillColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.brandBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAvailable
                                  ? AppStrings.providerAvailable.tr()
                                  : AppStrings.providerUnavailable.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightMainText,
                              ),
                            ),
                            4.height,
                            Text(
                              _isAvailable
                                  ? 'يتم تحديث موقعك تلقائياً للعملاء'
                                  : 'لن يظهر موقعك للعملاء',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.commentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_updatingAvailability)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Switch(
                          value: _isAvailable,
                          activeThumbColor: AppColors.primaryColor,
                          onChanged: _toggleAvailability,
                        ),
                    ],
                  ),
                ),
                16.height,
                const ProviderServiceOrdersPanel(),
                16.height,
                GestureDetector(
                  onTap: () async {
                    final value = await showLocationSheet(context);
                    if (!context.mounted) return;
                    if (value != null && value is LocationModel) {
                      context.read<LocationCubit>().addLocation(value);
                    }
                  },
                  child: Row(children: [
                    CustomIconButton.lightGreyBg(
                      padding: 12.r,
                      size: 48.w,
                      icon: AppIcons.add,
                      onTap: null,
                    ),
                    8.width,
                    Text(
                      AppStrings.addNewLocation.tr(),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ]),
                ),
                24.height,
                const Expanded(
                  child: LocationsList(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
