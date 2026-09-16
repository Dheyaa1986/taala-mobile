import 'dart:async';

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
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/service_type_catalog_sections.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_chat_launcher.dart';
import 'package:taal/features/service_orders/presentation/utils/towing_order_locations.dart';
import 'package:taal/features/service_orders/presentation/widgets/dual_location_preview_map.dart';

class CreateServiceOrderScreen extends StatefulWidget {
  const CreateServiceOrderScreen({super.key});

  @override
  State<CreateServiceOrderScreen> createState() =>
      _CreateServiceOrderScreenState();
}

class _CreateServiceOrderScreenState extends State<CreateServiceOrderScreen> {
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _placeSearch = getIt<PlaceSearchService>();
  final _destinationController = TextEditingController();
  final _searchFocus = FocusNode();

  List<ServiceCategoryCatalogModel> _catalog = [];
  String? _selectedServiceTypeId;
  PickedLocation? _clientLocation;
  PickedLocation? _destinationLocation;
  List<PlaceSuggestion> _suggestions = [];
  bool _loadingCatalog = true;
  bool _loadingGps = false;
  bool _searching = false;
  bool _submitting = false;
  bool _showMap = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _initClientLocation();
    _destinationController.addListener(_onDestinationTextChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _destinationController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _needsDestination {
    final code = _categoryCodeForSelectedType();
    return TowingOrderLocations.isTowingCategory(code);
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
      setState(() {
        _clientLocation = saved;
        _showMap = true;
      });
      return;
    }
    await _useCurrentLocation(silent: true);
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() => _loadingGps = true);
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;

    if (current == null) {
      setState(() => _loadingGps = false);
      if (!silent) {
        AppMessages.showError(
          context,
          AppStrings.locationPermissionDenied.tr(),
        );
      }
      return;
    }

    final address = await _geocoding.resolveAddress(
      current.latitude,
      current.longitude,
    );

    final picked = PickedLocation(
      latitude: current.latitude,
      longitude: current.longitude,
      address: address,
    );

    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), picked);

    if (!mounted) return;
    setState(() {
      _clientLocation = picked;
      _loadingGps = false;
      _showMap = true;
    });
  }

  Future<void> _pickClientOnMap() async {
    final result = await LocationPickerScreen.open(
      context,
      initial: _clientLocation,
    );
    if (result == null || !mounted) return;
    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), result);
    setState(() {
      _clientLocation = result;
      _showMap = true;
    });
  }

  Future<void> _pickDestinationOnMap() async {
    final result = await LocationPickerScreen.open(
      context,
      initial: _destinationLocation,
    );
    if (result == null || !mounted) return;
    await _applyDestination(result);
  }

  Future<void> _applyDestination(PickedLocation location) async {
    await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), location);
    if (!mounted) return;
    setState(() {
      _destinationLocation = location;
      _destinationController.text = location.address ?? '';
      _suggestions = [];
      _showMap = true;
    });
    _searchFocus.unfocus();
  }

  void _onDestinationTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final query = _destinationController.text.trim();
      if (query.length < 3) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      setState(() => _searching = true);
      final results = await _placeSearch.search(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
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

    if (_clientLocation == null) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }

    if (_needsDestination && _destinationLocation == null) {
      AppMessages.showError(
        context,
        AppStrings.towingDestinationRequired.tr(),
      );
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

    final profileResult = await getIt<ProfileRepository>().getMyProfile();
    final clientId = profileResult.fold((_) => null, (p) => p.id);
    if (clientId == null) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppMessages.showError(context, AppStrings.loginRequiredForHelp.tr());
      return;
    }

    final client = _clientLocation!;
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
          description: AppStrings.chatRequestDefault.tr(),
          serviceCategoryCode: _categoryCodeForSelectedType(),
          clientLocation: client,
          destinationLocation: _needsDestination ? _destinationLocation : null,
        );

        if (mounted) setState(() => _submitting = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        if (!_needsDestination) {
                          _destinationLocation = null;
                          _destinationController.clear();
                          _suggestions = [];
                        }
                      });
                    },
                  ),
                  24.height,
                  Text(
                    AppStrings.myLocation.tr(),
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
                  if (_needsDestination) ...[
                    24.height,
                    Text(
                      AppStrings.whereToGo.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    6.height,
                    Text(
                      AppStrings.searchDestinationHint.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.commentColor,
                        height: 1.4,
                      ),
                    ),
                    12.height,
                    TextField(
                      controller: _destinationController,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: AppStrings.typeDestinationHint.tr(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searching
                            ? Padding(
                                padding: REdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18.r,
                                  height: 18.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.textFieldFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (_suggestions.isNotEmpty) ...[
                      8.height,
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12.r),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined),
                              title: Text(
                                item.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.sp),
                              ),
                              onTap: () => _applyDestination(
                                PickedLocation(
                                  latitude: item.latitude,
                                  longitude: item.longitude,
                                  address: item.displayName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    12.height,
                    CustomButton.outlined(
                      text: AppStrings.pickLocationOnMap.tr(),
                      onTap: _pickDestinationOnMap,
                    ),
                  ],
                  if (_showMap && _clientLocation != null) ...[
                    24.height,
                    Text(
                      AppStrings.mapPreview.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    12.height,
                    DualLocationPreviewMap(
                      origin: _clientLocation!,
                      destination:
                          _needsDestination ? _destinationLocation : null,
                    ),
                  ],
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
