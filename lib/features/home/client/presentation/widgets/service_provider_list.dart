import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';

class ProvidersList extends StatefulWidget {
  const ProvidersList({super.key});

  @override
  State<ProvidersList> createState() => _ProvidersListState();
}

class _ProvidersListState extends State<ProvidersList> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceProvidersCubit>().getProviders(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
      builder: (context, state) {
        if (state is ServiceProvidersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ServiceProvidersError) {
          return Center(
            child: Text(
              state.error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.redColor,
              ),
            ),
          );
        }
        if (state is ServiceProvidersLoaded) {
          final providers = state.serviceProviders;
          if (providers.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noProvidersAvailable.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.commentColor,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: providers.length,
            separatorBuilder: (_, __) => 12.height,
            itemBuilder: (context, index) {
              return ServiceProviderCard(model: providers[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
