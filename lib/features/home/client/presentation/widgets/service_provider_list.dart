import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/fields/custom_search_field.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';

class ProvidersList extends StatefulWidget {
  const ProvidersList({
    super.key,
    this.showQuickActions = false,
    this.showSearch = false,
  });

  final bool showQuickActions;
  final bool showSearch;

  @override
  State<ProvidersList> createState() => _ProvidersListState();
}

class _ProvidersListState extends State<ProvidersList> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<ServiceProvidersCubit>().getProviders(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String? value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<ServiceProvidersCubit>().getProviders(
            reset: true,
            query: value?.trim() ?? '',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSearch) ...[
          CustomSearchField(
            controller: _searchController,
            hint: AppStrings.searchProvidersHint.tr(),
            onChanged: _onSearchChanged,
          ),
          12.height,
        ],
        Expanded(
          child: BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
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
                final cubit = context.read<ServiceProvidersCubit>();
                final providers = state.serviceProviders;
                if (providers.isEmpty) {
                  return Center(
                    child: Text(
                      cubit.searchQuery.isNotEmpty
                          ? AppStrings.noSearchResults.tr()
                          : AppStrings.noProvidersAvailable.tr(),
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
                    final provider = providers[index];
                    return ServiceProviderCard(
                      model: provider,
                      showQuickActions: widget.showQuickActions,
                      onRated: widget.showQuickActions
                          ? () => cubit.getProviders(reset: true)
                          : null,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
