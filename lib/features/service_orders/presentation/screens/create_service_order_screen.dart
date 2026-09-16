import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/service_types_audience.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/location_picker_screen.dart';
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
import 'package:taal/features/service_orders/presentation/widgets/order_destination_picker_section.dart';

class CreateServiceOrderScreen extends StatefulWidget {
  const CreateServiceOrderScreen({super.key, this.args});

  final CreateServiceOrderArgs? args;

  @override
  State<CreateServiceOrderScreen> createState() =>
      _CreateServiceOrderScreenState();
}

class _CreateServiceOrderScreenState extends State<CreateServiceOrderScreen> {
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _descriptionController = TextEditingController();

  List<ServiceCategoryCatalogModel> _catalog = [];
  String? _selectedServiceTypeId;
  PickedLocation? _clientLocation;
  PickedLocation? _destinationLocation;
  bool _loadingCatalog = true;
  bool _loadingGps = false;
  bool _submitting = false;
  bool _locationPermissionDenied = false;

  ServiceProviderModel? get _presetProvider => widget.args?.provider;

  @override
  void initState() {
    super.initState();
    _selectedServiceTypeId = widget.args?.serviceTypeId;
    _loadCatalog();
    _initClientLocation();
    _initDestination();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final result = await getIt<LocationsRepository>().getServiceCatalog(
      audience: ServiceTypesAudience.client,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingCatalog = false),
      (data) => setState(() {
        _catalog = data;
        _loadingCatalog = false;
      }),
    );
  }

  Future<void> _initClientLocation() async {
    final saved = await OrderLocationPrefs.readClient(getIt<SharedPref>());
    if (saved != null && mounted) {
      setState(() => _clientLocation = saved);
      return;
    }
    await _useCurrentLocation(silent: true);
  }

  Future<void> _initDestination() async {
    final saved = await OrderLocationPrefs.readDestination(getIt<SharedPref>());
    if (saved == null || !mounted) return;
    setState(() => _destinationLocation = saved);
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() {
      _loadingGps = true;
      _locationPermissionDenied = false;
    });
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;

    if (current == null) {
      setState(() {
        _loadingGps = false;
        _locationPermissionDenied = true;
      });
      if (!silent) {
        AppMessages.showError(
          context,
          AppStrings.locationPermissionDenied.tr(),
        );
      }
      return;
    }

    var picked = PickedLocation(
      latitude: current.latitude,
      longitude: current.longitude,
    );
    picked = await OrderLocationPrefs.ensureAddress(picked, _geocoding);
    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), picked);

    if (!mounted) return;
    setState(() {
      _clientLocation = picked;
      _loadingGps = false;
    });
  }

  Future<void> _pickClientOnMap() async {
    final result = await LocationPickerScreen.open(
      context,
      initial: _clientLocation,
    );
    if (result == null || !mounted) return;
    final resolved = await OrderLocationPrefs.ensureAddress(result, _geocoding);
    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), resolved);
    setState(() {
      _clientLocation = resolved;
      _locationPermissionDenied = false;
    });
  }

  Future<void> _onDestinationChanged(PickedLocation location) async {
    final resolved = await OrderLocationPrefs.ensureAddress(location, _geocoding);
    await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), resolved);
    if (!mounted) return;
    setState(() => _destinationLocation = resolved);
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

  Future<PickedLocation?> _resolveClientForSubmit() async {
    if (_clientLocation == null) return null;
    final resolved =
        await OrderLocationPrefs.ensureAddress(_clientLocation!, _geocoding);
    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), resolved);
    return resolved;
  }

  Future<PickedLocation?> _resolveDestinationForSubmit() async {
    if (_destinationLocation == null) return null;
    final resolved = await OrderLocationPrefs.ensureAddress(
      _destinationLocation!,
      _geocoding,
    );
    await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), resolved);
    return resolved;
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

    final client = await _resolveClientForSubmit();
    if (!OrderLocationPrefsValidators.isValidClient(client)) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }

    final destination = await _resolveDestinationForSubmit();
    if (!OrderLocationPrefsValidators.isValidDestination(destination)) {
      AppMessages.showError(context, AppStrings.destinationRequired.tr());
      return;
    }

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

    final presetProvider = _presetProvider;
    if (presetProvider != null) {
      await ServiceOrderChatLauncher.startChat(
        provider: presetProvider,
        serviceTypeId: _selectedServiceTypeId!,
        description: orderDescription,
        serviceCategoryCode: _categoryCodeForSelectedType(),
        clientLocation: client,
        destinationLocation: destination,
        popRoutesBeforeDetail: 1,
      );
      if (mounted) setState(() => _submitting = false);
      return;
    }

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
        clientLatitude: client!.latitude,
        clientLongitude: client.longitude,
      ),
    );

    if (!mounted) return;

    await providersResult.fold(
      (error) async {
        setState(() => _submitting = false);
        AppMessages.showError(context, error.message);
      },
      (providers) async {
        if (providers.isEmpty) {
          setState(() => _submitting = false);
          AppMessages.showError(context, AppStrings.noProvidersNearby.tr());
          return;
        }

        await ServiceOrderChatLauncher.startChat(
          provider: providers.first,
          serviceTypeId: _selectedServiceTypeId!,
          description: orderDescription,
          serviceCategoryCode: _categoryCodeForSelectedType(),
          clientLocation: client,
          destinationLocation: destination,
          popRoutesBeforeDetail: 1,
        );

        if (mounted) setState(() => _submitting = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final presetProvider = _presetProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createOrderTitle.tr()),
        centerTitle: true,
      ),
      body: _loadingCatalog
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: REdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + context.safeBottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  if (_locationPermissionDenied) ...[
                    YellowHighlightCard(
                      isHighlighted: true,
                      child: Text(
                        AppStrings.locationPermissionDenied.tr(),
                        style: TextStyle(fontSize: 13.sp, height: 1.4),
                      ),
                    ),
                    12.height,
                  ],
                  Text(
                    AppStrings.createOrderStepService.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  12.height,
                  ServiceTypeCatalogSections(
                    categories: _catalog,
                    selectedIds: _selectedServiceTypeId == null
                        ? {}
                        : {_selectedServiceTypeId!},
                    multiSelect: false,
                    onChanged: (ids) {
                      setState(() {
                        _selectedServiceTypeId =
                            ids.isEmpty ? null : ids.first;
                      });
                    },
                  ),
                  24.height,
                  Text(
                    AppStrings.createOrderStepLocation.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  8.height,
                  _LocationCard(
                    location: _clientLocation,
                    loading: _loadingGps,
                    onUseGps: () => _useCurrentLocation(),
                    onPickMap: _pickClientOnMap,
                  ),
                  24.height,
                  OrderDestinationPickerSection(
                    clientLocation: _clientLocation,
                    destination: _destinationLocation,
                    onDestinationChanged: _onDestinationChanged,
                  ),
                  24.height,
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
            ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.loading,
    required this.onUseGps,
    required this.onPickMap,
  });

  final PickedLocation? location;
  final bool loading;
  final VoidCallback onUseGps;
  final VoidCallback onPickMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.textFieldFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.brandBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (location != null) ...[
            Text(
              location!.address ?? AppStrings.locationPicked.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.lightMainText,
                height: 1.4,
              ),
            ),
            6.height,
            Text(
              '${location!.lat}, ${location!.lng}',
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
            12.height,
          ] else
            Text(
              AppStrings.noLocationSelected.tr(),
              style: TextStyle(fontSize: 13.sp, color: AppColors.commentColor),
            ),
          Row(
            children: [
              Expanded(
                child: CustomButton.filled(
                  text: AppStrings.useCurrentLocationNow.tr(),
                  onTap: loading ? null : onUseGps,
                  height: 44.h,
                ),
              ),
              8.width,
              Expanded(
                child: CustomButton.outlined(
                  text: AppStrings.pickLocationOnMap.tr(),
                  onTap: onPickMap,
                  height: 44.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
