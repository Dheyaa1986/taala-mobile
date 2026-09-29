import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/service_types_audience.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/back_button.dart';
import 'package:taal/core/widgets/service_type_catalog_sections.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_list.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

class ClientServicesScreen extends StatefulWidget {
  const ClientServicesScreen({super.key});

  @override
  State<ClientServicesScreen> createState() => _ClientServicesScreenState();
}

class _ClientServicesScreenState extends State<ClientServicesScreen> {
  List<ServiceCategoryCatalogModel> _catalog = [];
  bool _loadingCatalog = true;
  bool _catalogError = false;
  String? _selectedServiceTypeId;
  String? _selectedServiceTypeName;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final isGuest = await GuestSessionHelper.isGuestBrowsing();
    final audience =
        isGuest ? ServiceTypesAudience.guest : ServiceTypesAudience.client;
    final result = await getIt<LocationsRepository>().getServiceCatalog(
      audience: audience,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loadingCatalog = false;
        _catalogError = true;
      }),
      (data) => setState(() {
        _catalog = data;
        _loadingCatalog = false;
      }),
    );
  }

  String? _resolveServiceTypeName(String id) {
    for (final category in _catalog) {
      for (final type in category.serviceTypes) {
        if (type.id == id) return type.name;
      }
    }
    return null;
  }

  void _onServiceTypeSelected(
    BuildContext context,
    Set<String> ids,
  ) {
    if (ids.isEmpty) return;
    final id = ids.first;
    context.read<ServiceProvidersCubit>().updateFilter(
          FilterProvidersModel(serviceTypeId: id, active: true),
        );
    setState(() {
      _selectedServiceTypeId = id;
      _selectedServiceTypeName = _resolveServiceTypeName(id);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedServiceTypeId = null;
      _selectedServiceTypeName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceProvidersCubit(
        repository: getIt<ProviderRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final showingProviders = _selectedServiceTypeId != null;

          return Scaffold(
            appBar: CustomAppBar.langAppBar(
              showProfileIcon: !showingProviders,
              leading: showingProviders
                  ? CustomBackButton(onPressed: _clearSelection)
                  : null,
              title: showingProviders
                  ? (_selectedServiceTypeName ?? AppStrings.services.tr())
                  : AppStrings.services.tr(),
              centerTitle: true,
            ),
            body: Padding(
              padding: REdgeInsets.fromLTRB(16, 16, 16, 16),
              child: showingProviders
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.servicesProvidersForType.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: TaalaTokens.of(context).textSecondary,
                            height: 1.5,
                          ),
                        ),
                        16.height,
                        const Expanded(
                          child: ProvidersList(
                            showQuickActions: true,
                            showSearch: true,
                            loadOnInit: false,
                          ),
                        ),
                      ],
                    )
                  : _buildCatalog(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    if (_loadingCatalog) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.servicesSubtitle.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: TaalaTokens.of(context).textSecondary,
              height: 1.5,
            ),
          ),
          16.height,
          if (_catalogError)
            Center(
              child: Text(
                AppStrings.genericError.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: TaalaTokens.of(context).error,
                ),
              ),
            )
          else
            ServiceTypeCatalogSections(
              categories: _catalog,
              selectedIds: const {},
              multiSelect: false,
              isLoadError: _catalogError,
              onChanged: (ids) => _onServiceTypeSelected(context, ids),
            ),
        ],
      ),
    );
  }
}
