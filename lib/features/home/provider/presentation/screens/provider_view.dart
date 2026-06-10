import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/add_location_sheet.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../widgets/locations_list.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  TextEditingController searchController = TextEditingController();
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
          ),
          body: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                GestureDetector(
                  onTap: () async {
                    await showLocationSheet(context).then((value) {
                      if (value != null && value is LocationModel) {
                        context.read<LocationCubit>().addLocation(value);
                      }
                    },);
                  },
                  child: Row(children: [
                    CustomIconButton.lightGreyBg(
                     padding: 12.r,
                      size: 48.w,
                      icon: AppIcons.add,

                      onTap:null,
                    ),
                    8.width,
                    Text(AppStrings.addNewLocation.tr(),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            )),
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
