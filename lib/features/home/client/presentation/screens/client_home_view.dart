import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/data/iraq_governorates.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/fields/map_location_picker_field.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';
import 'package:taal/features/service_orders/presentation/widgets/service_order_help_sheet.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  PickedLocation? _pickedLocation;
  IraqGovernorate? _selectedGovernorate;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = getIt<SharedPref>();
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    final mapLink = await prefs.get(key: PrefsKeys.clientLocationMapLink);
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);
    final governorateName =
        await prefs.get(key: PrefsKeys.clientLocationGovernorate);
    if (!mounted) return;
    if (address is String) _addressController.text = address;
    if (governorateName is String && governorateName.isNotEmpty) {
      for (final governorate in iraqGovernorates) {
        if (governorate.nameAr == governorateName ||
            governorate.nameEn == governorateName) {
          _selectedGovernorate = governorate;
          break;
        }
      }
    }
    if (lat is String && lng is String) {
      final parsedLat = double.tryParse(lat);
      final parsedLng = double.tryParse(lng);
      if (parsedLat != null && parsedLng != null) {
        _pickedLocation = PickedLocation(
          latitude: parsedLat,
          longitude: parsedLng,
          address: address is String ? address : null,
        );
      }
    } else if (mapLink is String && mapLink.isNotEmpty) {
      try {
        _pickedLocation = PickedLocation.fromGoogleMapsUrl(
          mapLink,
          address: address is String ? address : null,
        );
      } catch (_) {}
    }
    setState(() {});
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingGps = true);
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);

    if (current == null) {
      AppMessages.showError(context, AppStrings.locationPermissionDenied.tr());
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

    setState(() {
      _pickedLocation = picked;
      if (address != null && address.isNotEmpty) {
        _addressController.text = address;
      }
    });

    await _saveLocation(showSuccess: true);
  }

  Future<void> _saveLocation({bool showSuccess = false}) async {
    if (_pickedLocation == null) {
      if (!_formKey.currentState!.validate()) return;
    } else if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = getIt<SharedPref>();
    await prefs.set(
      key: PrefsKeys.clientLocationAddress,
      value: _addressController.text.trim(),
    );
    await prefs.set(
      key: PrefsKeys.clientLocationGovernorate,
      value: _selectedGovernorate!.nameAr,
    );
    if (_pickedLocation != null) {
      await prefs.set(
        key: PrefsKeys.clientLocationMapLink,
        value: _pickedLocation!.googleMapsUrl,
      );
      await prefs.set(
        key: PrefsKeys.clientLocationLat,
        value: _pickedLocation!.lat,
      );
      await prefs.set(
        key: PrefsKeys.clientLocationLng,
        value: _pickedLocation!.lng,
      );
    }
    if (mounted && showSuccess) {
      AppMessages.showSuccess(context, AppStrings.locationSaved.tr());
    }
  }

  void _onLocationPicked(PickedLocation location) {
    setState(() {
      _pickedLocation = location;
      if (_addressController.text.trim().isEmpty &&
          location.address != null &&
          location.address!.isNotEmpty) {
        _addressController.text = location.address!;
      }
    });
    _saveLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceProvidersCubit(
        repository: getIt<ProviderRepository>(),
      ),
      child: _ClientHomeBody(
        formKey: _formKey,
        addressController: _addressController,
        pickedLocation: _pickedLocation,
        selectedGovernorate: _selectedGovernorate,
        loadingGps: _loadingGps,
        onUseCurrentLocation: _useCurrentLocation,
        onLocationPicked: _onLocationPicked,
        onGovernorateChanged: (value) =>
            setState(() => _selectedGovernorate = value),
        onSaveLocation: () => _saveLocation(showSuccess: true),
        initialLoad: _pickedLocation != null,
      ),
    );
  }
}

class _ClientHomeBody extends StatefulWidget {
  const _ClientHomeBody({
    required this.formKey,
    required this.addressController,
    required this.pickedLocation,
    required this.selectedGovernorate,
    required this.loadingGps,
    required this.onUseCurrentLocation,
    required this.onLocationPicked,
    required this.onGovernorateChanged,
    required this.onSaveLocation,
    required this.initialLoad,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController addressController;
  final PickedLocation? pickedLocation;
  final IraqGovernorate? selectedGovernorate;
  final bool loadingGps;
  final Future<void> Function() onUseCurrentLocation;
  final void Function(PickedLocation) onLocationPicked;
  final void Function(dynamic) onGovernorateChanged;
  final VoidCallback onSaveLocation;
  final bool initialLoad;

  @override
  State<_ClientHomeBody> createState() => _ClientHomeBodyState();
}

class _ClientHomeBodyState extends State<_ClientHomeBody> {
  @override
  void initState() {
    super.initState();
    _loadProvidersIfNeeded(widget.pickedLocation, force: widget.initialLoad);
  }

  @override
  void didUpdateWidget(covariant _ClientHomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickedLocation != oldWidget.pickedLocation) {
      _loadProvidersIfNeeded(widget.pickedLocation);
    }
  }

  void _loadProvidersIfNeeded(PickedLocation? location, {bool force = false}) {
    if (location == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServiceProvidersCubit>().loadNearestAvailable(
            latitude: location.latitude,
            longitude: location.longitude,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: CustomAppBar.langAppBar(
              showProfileIcon: true,
              title: AppStrings.home.tr(),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: AppStrings.myServiceOrders.tr(),
                  icon: const Icon(Icons.assignment_outlined),
                  onPressed: () => context.pushNamed(Routes.serviceOrders),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: REdgeInsets.all(16),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.clientHomeWelcome.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    8.height,
                    Text(
                      AppStrings.clientHomeSubtitle.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.commentColor,
                        height: 1.5,
                      ),
                    ),
                    16.height,
                    CustomButton.filled(
                      text: AppStrings.useCurrentLocationNow.tr(),
                      onTap: widget.loadingGps ? null : widget.onUseCurrentLocation,
                      height: 48.h,
                    ),
                    20.height,
                    YellowHighlightCard(
                      isHighlighted: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.myLocation.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightMainText,
                            ),
                          ),
                          12.height,
                          CustomDropDownField<IraqGovernorate?>(
                            value: widget.selectedGovernorate,
                            label: AppStrings.governorate.tr(),
                            hint: AppStrings.governorate.tr(),
                            validator: CustomValidators.validateDropDown,
                            onChanged: widget.onGovernorateChanged,
                            items: iraqGovernorates
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g.nameAr),
                                  ),
                                )
                                .toList(),
                          ),
                          12.height,
                          MapLocationPickerField(
                            value: widget.pickedLocation,
                            onChanged: widget.onLocationPicked,
                            validator: CustomValidators.validatePickedLocation,
                          ),
                          12.height,
                          CustomTextField(
                            controller: widget.addressController,
                            label: AppStrings.address.tr(),
                            hint: AppStrings.enterAddress.tr(),
                            validator: CustomValidators.validateEmpty,
                          ),
                          12.height,
                          CustomButton.outlined(
                            text: AppStrings.save.tr(),
                            onTap: widget.onSaveLocation,
                          ),
                        ],
                      ),
                    ),
                    24.height,
                    Text(
                      AppStrings.nearestProviders.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    12.height,
                    BlocBuilder<ServiceProvidersCubit, ServiceProvidersState>(
                      builder: (context, state) {
                        if (state is ServiceProvidersLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (state is ServiceProvidersError) {
                          return Text(
                            state.error,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.redColor,
                            ),
                          );
                        }
                        if (state is ServiceProvidersLoaded &&
                            state.serviceProviders.isEmpty) {
                          return Text(
                            AppStrings.noProvidersNearby.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.commentColor,
                            ),
                          );
                        }
                        if (state is ServiceProvidersLoaded) {
                          return Column(
                            children: state.serviceProviders
                                .map(
                                  (provider) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: ServiceProviderCard(model: provider),
                                  ),
                                )
                                .toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    24.height,
                    CustomButton.filled(
                      text: AppStrings.requestHelp.tr(),
                      onTap: () => showServiceOrderHelpSheet(context),
                      height: 52.h,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
