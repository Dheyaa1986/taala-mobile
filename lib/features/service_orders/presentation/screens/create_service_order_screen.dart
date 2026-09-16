import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/service_types_audience.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/service_type_catalog_sections.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/models/create_service_order_args.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_chat_launcher.dart';
import 'package:taal/features/service_orders/presentation/widgets/dual_location_preview_map.dart';
import 'package:taal/features/service_orders/presentation/widgets/order_location_confirm_step.dart';
import 'package:taal/features/service_orders/presentation/widgets/order_wizard_step_indicator.dart';

class CreateServiceOrderScreen extends StatefulWidget {
  const CreateServiceOrderScreen({super.key, this.args});

  final CreateServiceOrderArgs? args;

  @override
  State<CreateServiceOrderScreen> createState() =>
      _CreateServiceOrderScreenState();
}

class _CreateServiceOrderScreenState extends State<CreateServiceOrderScreen> {
  static const _stepDeparture = 0;
  static const _stepDestination = 1;
  static const _stepService = 2;

  final _descriptionController = TextEditingController();

  int _step = _stepDeparture;
  PickedLocation? _clientLocation;
  PickedLocation? _destinationLocation;
  List<ServiceCategoryCatalogModel> _catalog = [];
  String? _selectedServiceTypeId;
  bool _loadingCatalog = true;
  String? _catalogError;
  bool _submitting = false;
  bool _highlightServiceStep = false;

  ServiceProviderModel? get _presetProvider => widget.args?.provider;

  @override
  void initState() {
    super.initState();
    _selectedServiceTypeId = widget.args?.serviceTypeId;
    _loadCatalog();
    _loadSavedLocations();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocations() async {
    final prefs = getIt<SharedPref>();
    final client = await OrderLocationPrefs.readClient(prefs);
    final destination = await OrderLocationPrefs.readDestination(prefs);
    if (!mounted) return;
    setState(() {
      _clientLocation = client;
      _destinationLocation = destination;
    });
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loadingCatalog = true;
      _catalogError = null;
    });
    final result = await getIt<LocationsRepository>().getServiceCatalog(
      audience: ServiceTypesAudience.client,
    );
    if (!mounted) return;
    result.fold(
      (error) => setState(() {
        _loadingCatalog = false;
        _catalogError = error.message;
      }),
      (data) => setState(() {
        _catalog = data;
        _loadingCatalog = false;
        _catalogError = null;
      }),
    );
  }

  ServiceTypeModel? _selectedServiceType() {
    for (final category in _catalog) {
      for (final type in category.serviceTypes) {
        if (type.id == _selectedServiceTypeId) return type;
      }
    }
    return null;
  }

  String? _categoryCodeForSelectedType() {
    final selected = _selectedServiceType();
    if (selected == null) return null;
    for (final category in _catalog) {
      if (category.serviceTypes.any((type) => type.id == selected.id)) {
        return selected.categoryCode ?? category.code;
      }
    }
    return selected.categoryCode;
  }

  Future<void> _onDepartureConfirmed(PickedLocation location) async {
    final resolved = await OrderLocationPrefs.ensureAddress(
      location,
      getIt<ReverseGeocodingService>(),
    );
    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), resolved);
    if (!mounted) return;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    AppMessages.showSuccess(
      context,
      AppStrings.departurePointConfirmed.tr(),
    );
    setState(() {
      _clientLocation = resolved;
      _step = _stepDestination;
      _highlightServiceStep = false;
    });
  }

  Future<void> _onDestinationConfirmed(PickedLocation location) async {
    final resolved = await OrderLocationPrefs.ensureAddress(
      location,
      getIt<ReverseGeocodingService>(),
    );
    await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), resolved);
    if (!mounted) return;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    AppMessages.showSuccess(
      context,
      AppStrings.destinationPointConfirmed.tr(),
    );
    setState(() {
      _destinationLocation = resolved;
      _step = _stepService;
      _highlightServiceStep = true;
    });
  }

  Future<void> _submit() async {
    if (_selectedServiceTypeId == null) {
      AppMessages.showError(context, AppStrings.selectServiceType.tr());
      return;
    }

    final selectedType = _selectedServiceType();
    if (selectedType != null && !selectedType.isEnabled) {
      AppMessages.showError(context, AppStrings.serviceUnavailable.tr());
      return;
    }

    if (_clientLocation == null || _destinationLocation == null) {
      AppMessages.showError(context, AppStrings.destinationRequired.tr());
      return;
    }

    final geocoding = getIt<ReverseGeocodingService>();
    final client = await OrderLocationPrefs.ensureAddress(
      _clientLocation!,
      geocoding,
    );
    final destination = await OrderLocationPrefs.ensureAddress(
      _destinationLocation!,
      geocoding,
    );
    if (!mounted) return;

    if (!OrderLocationPrefsValidators.isValidClient(client)) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }
    if (!OrderLocationPrefsValidators.isValidDestination(destination)) {
      AppMessages.showError(context, AppStrings.destinationRequired.tr());
      return;
    }

    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), client);
    await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), destination);

    final allowed = await ClientProfileGuard.ensureReadyForNewOrder(context);
    if (!allowed || !mounted) return;

    final activeOrder =
        await getIt<ServiceOrderRepository>().getActiveOrder();
    if (!mounted) return;
    final blocked = activeOrder.fold(
      (_) => false,
      (order) => order?.id != null,
    );
    if (blocked) {
      AppMessages.showError(
        context,
        AppStrings.activeOrderBlockingSearch.tr(),
      );
      return;
    }

    setState(() => _submitting = true);

    final description = _descriptionController.text.trim();
    final orderDescription = description.isEmpty
        ? AppStrings.chatRequestDefault.tr()
        : description;

    ServiceProviderModel? selectedProvider = _presetProvider;

    if (selectedProvider == null) {
      final profileResult = await getIt<ProfileRepository>().getMyProfile();
      final clientId = profileResult.fold((_) => null, (p) => p.id);
      if (clientId == null) {
        if (!mounted) return;
        setState(() => _submitting = false);
        AppMessages.showError(context, AppStrings.loginRequiredForHelp.tr());
        return;
      }

      final providersResult = await getIt<ProviderRepository>().getProviders(
        clientId: clientId,
        options: ProvidersPaginationOptions(
          page: 1,
          limit: 1,
          filter: FilterProvidersModel(
            serviceTypeId: _selectedServiceTypeId,
            active: true,
          ),
          clientLatitude: client.latitude,
          clientLongitude: client.longitude,
        ),
      );

      if (!mounted) return;

      selectedProvider = providersResult.fold(
        (_) => null,
        (providers) => providers.isEmpty ? null : providers.first,
      );
    }

    await ServiceOrderChatLauncher.startChat(
      provider: selectedProvider,
      serviceTypeId: _selectedServiceTypeId!,
      description: orderDescription,
      serviceCategoryCode: _categoryCodeForSelectedType(),
      clientLocation: client,
      destinationLocation: destination,
      popRoutesBeforeDetail: 1,
    );

    if (mounted) setState(() => _submitting = false);
  }

  String _stepTitle() {
    switch (_step) {
      case _stepDeparture:
        return AppStrings.orderStepDeparture.tr();
      case _stepDestination:
        return AppStrings.orderStepDestination.tr();
      default:
        return AppStrings.orderStepService.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        centerTitle: true,
        leading: _step > _stepDeparture
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _step -= 1);
                },
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderWizardStepIndicator(currentStep: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ));
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_step),
                child: _buildStepBody(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBody(BuildContext context) {
    return switch (_step) {
      _stepDeparture => OrderLocationConfirmStep(
          title: AppStrings.departurePointHint.tr(),
          confirmLabel: AppStrings.confirmDeparturePoint.tr(),
          initial: _clientLocation,
          onConfirmed: _onDepartureConfirmed,
        ),
      _stepDestination => OrderLocationConfirmStep(
          title: AppStrings.destinationPointHint.tr(),
          confirmLabel: AppStrings.confirmDestinationPoint.tr(),
          initial: _destinationLocation ?? _clientLocation,
          autoGpsOnStart: false,
          onConfirmed: _onDestinationConfirmed,
        ),
      _ => _buildServiceStep(context),
    };
  }

  Widget _buildServiceStep(BuildContext context) {
    final presetProvider = _presetProvider;

    if (_loadingCatalog) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      key: const ValueKey('service_step_scroll'),
      padding: REdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + context.safeBottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_highlightServiceStep) ...[
            YellowHighlightCard(
              isHighlighted: true,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 22.r,
                  ),
                  10.width,
                  Expanded(
                    child: Text(
                      AppStrings.destinationPointConfirmed.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            16.height,
          ],
          if (presetProvider != null) ...[
            YellowHighlightCard(
              isHighlighted: true,
              child: Text(
                AppStrings.orderWithSelectedProvider.tr(
                  namedArgs: {'name': presetProvider.name ?? ''},
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            16.height,
          ],
          if (_clientLocation != null && _destinationLocation != null) ...[
            DualLocationPreviewMap(
              origin: _clientLocation!,
              destination: _destinationLocation,
              height: 240.h,
            ),
            8.height,
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _step = _stepDeparture),
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: Text(AppStrings.editDeparturePoint.tr()),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _step = _stepDestination),
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: Text(AppStrings.editDestinationPoint.tr()),
                ),
              ],
            ),
            16.height,
          ],
          Text(
            AppStrings.createOrderStepService.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          12.height,
          if (_catalogError != null) ...[
            Text(
              _catalogError!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.error,
                height: 1.4,
              ),
            ),
            8.height,
            TextButton.icon(
              onPressed: _loadingCatalog ? null : _loadCatalog,
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.retry.tr()),
            ),
            12.height,
          ],
          ServiceTypeCatalogSections(
            categories: _catalog,
            selectedIds: _selectedServiceTypeId == null
                ? {}
                : {_selectedServiceTypeId!},
            multiSelect: false,
            isLoadError: _catalogError != null,
            onChanged: (ids) {
              setState(() {
                _selectedServiceTypeId = ids.isEmpty ? null : ids.first;
              });
            },
          ),
          20.height,
          CustomTextField(
            controller: _descriptionController,
            label: AppStrings.description.tr(),
            hint: AppStrings.enterDescription.tr(),
            maxLines: 3,
          ),
          28.height,
          CustomButton.filled(
            text: AppStrings.requestHelp.tr(),
            onTap: _submitting ? null : _submit,
            enabled: !_submitting,
            height: 52.h,
          ),
          if (_submitting) ...[
            12.height,
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
