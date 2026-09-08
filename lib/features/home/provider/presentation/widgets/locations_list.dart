import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/home/provider/presentation/widgets/location_card.dart';

class LocationsList extends StatefulWidget {
  const LocationsList({
    super.key,
  });

  @override
  State<LocationsList> createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {
  @override
  void initState() {
    context.read<LocationCubit>().getLocations();
    super.initState();
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: REdgeInsets.symmetric(vertical: 32),
        child: Text(
          AppStrings.noLocationsYet.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.commentColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            if (state is LocationsLoaded) {
              final locations = state.locations;
              if (locations.isEmpty) {
                return SliverToBoxAdapter(child: _emptyState());
              }

              return SliverList.separated(
                separatorBuilder: (context, index) => 16.height,
                itemBuilder: (context, index) {
                  return LocationCard(model: locations[index]);
                },
                itemCount: locations.length,
              );
            } else if (state is LocationsEmpty) {
              return SliverToBoxAdapter(child: _emptyState());
            } else if (state is LocationsLoading) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            } else if (state is LocationsError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: REdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.commentColor,
                    ),
                  ),
                ),
              );
            } else {
              return const SliverToBoxAdapter(child: SizedBox());
            }
          },
        ),
        SliverToBoxAdapter(child: 20.height),
      ],
    );
  }
}
