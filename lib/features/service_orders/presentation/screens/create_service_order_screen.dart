import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';
import 'package:taal/features/service_orders/presentation/widgets/order_tracking_map.dart';
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
import 'package:taal/design_system/components/taala_button.dart';
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
import 'package:taal/features/service_orders/presentation/widgets/dual_location_preview_map.dart';
import 'package:taal/features/service_orders/presentation/widgets/order_location_confirm_step.dart';
import 'package:taal/core/provider_offering/provider_offering_mode.dart';
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
  static const _stepTracking = 3;

  final _descriptionController = TextEditingController();

  int _step = _stepDeparture;
  String? _trackingOrderId;
  ServiceOrderModel? _trackingOrder;
  ServiceOrderTrackingModel? _trackingInfo;
  Timer? _trackingTimer;
  PickedLocation? _clientLocation;
  PickedLocation? _destinationLocation;
  List<ServiceCategoryCatalogModel> _catalog = [];
  String? _selectedServiceTypeId;
  bool _loadingCatalog = true;
  String? _catalogError;
  bool _submitting = false;
  bool _highlightServiceStep = false;

  ServiceProviderModel? get _presetProvider => widget.args?.provider;

  ServiceOrderVisitType get _visitType =>
      widget.args?.visitType ?? ServiceOrderVisitType.mobileOnSite;

  bool get _isCraneOrder {
    final type = _selectedServiceType();
    return isMobileOnlyServiceCategory(type?.categoryCode);
  }

  bool get _skipDestination =>
      !_isCraneOrder && _visitType == ServiceOrderVisitType.mobileOnSite;

  int get _wizardDisplayStep {
    if (_skipDestination) {
      return _step >= _stepService ? 1 : 0;
    }
    return _step.clamp(0, _stepService);
  }

  @override
  void initState() {
    super.initState();
    _selectedServiceTypeId = widget.args?.serviceTypeId;
    _loadCatalog();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _descriptionController.dispose();
    super.dispose();
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
      _step = _skipDestination ? _stepService : _stepDestination;
      _highlightServiceStep = _skipDestination;
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

    if (_clientLocation == null) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }
    if (!_skipDestination && _destinationLocation == null) {
      AppMessages.showError(context, AppStrings.destinationRequired.tr());
      return;
    }

    final geocoding = getIt<ReverseGeocodingService>();
    final client = await OrderLocationPrefs.ensureAddress(
      _clientLocation!,
      geocoding,
    );
    PickedLocation? destination;
    if (!_skipDestination && _destinationLocation != null) {
      destination = await OrderLocationPrefs.ensureAddress(
        _destinationLocation!,
        geocoding,
      );
    }
    if (!mounted) return;

    if (!OrderLocationPrefsValidators.isValidClient(client)) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }
    if (!_skipDestination) {
      if (destination == null ||
          !OrderLocationPrefsValidators.isValidDestination(destination)) {
        AppMessages.showError(context, AppStrings.destinationRequired.tr());
        return;
      }
    }

    await OrderLocationPrefs.saveClient(getIt<SharedPref>(), client);
    if (destination != null) {
      await OrderLocationPrefs.saveDestination(getIt<SharedPref>(), destination);
    }
    if (!mounted) return;

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

    final providerId = selectedProvider?.id?.trim();

    final createResult = await getIt<ServiceOrderRepository>().createOrder(
      serviceTypeId: _selectedServiceTypeId!,
      description: orderDescription,
      providerId: (providerId == null || providerId.isEmpty) ? null : providerId,
      clientAddress: client.address,
      clientLatitude: client.latitude,
      clientLongitude: client.longitude,
      destinationAddress: destination?.address,
      destinationLatitude: destination?.latitude,
      destinationLongitude: destination?.longitude,
      visitType: _visitType,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    createResult.fold(
      (error) {
        if (error.message.contains('ملفك')) {
          ClientProfileGuard.ensureReadyForNewOrder(context);
          return;
        }
        AppMessages.showError(context, error.message);
      },
      (order) {
        final orderId = order.id;
        if (orderId == null || orderId.isEmpty) {
          AppMessages.showError(context, AppStrings.chatOpenFailed.tr());
          return;
        }
        getIt<ActiveOrderRefreshNotifier>().notifyChanged();
        setState(() {
          _trackingOrderId = orderId;
          _trackingOrder = order;
          _step = _stepTracking;
        });
        _startTrackingPoll(orderId);
        AppMessages.showSuccess(context, AppStrings.orderSubmittedTrackOnMap.tr());
      },
    );
  }

  void _startTrackingPoll(String orderId) {
    _trackingTimer?.cancel();
    unawaited(_refreshTracking(orderId));
    _trackingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_refreshTracking(orderId));
    });
  }

  Future<void> _refreshTracking(String orderId) async {
    final repo = getIt<ServiceOrderRepository>();
    final orderResult = await repo.getOrder(orderId);
    final trackingResult = await repo.getTracking(orderId);
    if (!mounted) return;
    orderResult.fold((_) {}, (order) {
      setState(() => _trackingOrder = order);
    });
    trackingResult.fold((_) {}, (tracking) {
      setState(() => _trackingInfo = tracking);
    });
  }

  String _stepTitle() {
    switch (_step) {
      case _stepDeparture:
        return AppStrings.orderStepDeparture.tr();
      case _stepDestination:
        return AppStrings.orderStepDestination.tr();
      case _stepService:
        return AppStrings.orderStepService.tr();
      default:
        return AppStrings.trackProviderOnMap.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        centerTitle: true,
        leading: _step > _stepDeparture && _step < _stepTracking
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_skipDestination && _step == _stepService) {
                      _step = _stepDeparture;
                    } else {
                      _step -= 1;
                    }
                  });
                },
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_step < _stepTracking)
            OrderWizardStepIndicator(
              currentStep: _wizardDisplayStep,
              skipDestination: _skipDestination,
            ),
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
          followLiveLocation: true,
          onConfirmed: _onDepartureConfirmed,
        ),
      _stepDestination => OrderLocationConfirmStep(
          title: AppStrings.destinationPointHint.tr(),
          confirmLabel: AppStrings.confirmDestinationPoint.tr(),
          initial: _destinationLocation,
          referenceLocation: _clientLocation,
          searchHint: AppStrings.searchDestinationHint.tr(),
          autoGpsOnStart: false,
          onConfirmed: _onDestinationConfirmed,
        ),
      _stepService => _buildServiceStep(context),
      _ => _buildTrackingStep(context),
    };
  }

  Widget _buildTrackingStep(BuildContext context) {
    final order = _trackingOrder;
    final clientLat = order?.clientLatitude ?? _clientLocation?.latitude;
    final clientLng = order?.clientLongitude ?? _clientLocation?.longitude;
    final destinationLat =
        order?.destinationLatitude ?? _destinationLocation?.latitude;
    final destinationLng =
        order?.destinationLongitude ?? _destinationLocation?.longitude;

    if (clientLat == null || clientLng == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final providerLat = _trackingInfo?.providerLatitude;
    final providerLng = _trackingInfo?.providerLongitude;

    return Column(
      key: const ValueKey('tracking_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: OrderTrackingMap(
            expandToFill: true,
            clientLatitude: clientLat,
            clientLongitude: clientLng,
            providerLatitude: providerLat,
            providerLongitude: providerLng,
            destinationLatitude: destinationLat,
            destinationLongitude: destinationLng,
          ),
        ),
        Padding(
          padding: REdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + context.safeBottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                providerLat == null
                    ? AppStrings.orderTrackingWaitingProvider.tr()
                    : AppStrings.trackProviderOnMap.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_trackingInfo?.etaMinutes != null) ...[
                6.height,
                Text(
                  '${_trackingInfo!.etaMinutes} ${AppStrings.minutes.tr()}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              12.height,
              TaalaButton(
                label: AppStrings.openChat.tr(),
                onPressed: _trackingOrderId == null
                    ? null
                    : () {
                        ServiceOrderNavigation.openDetail(
                          _trackingOrderId!,
                          openChat: true,
                        );
                      },
                height: 48,
              ),
            ],
          ),
        ),
      ],
    );
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
          if (_clientLocation != null &&
              (_destinationLocation != null || _skipDestination)) ...[
            DualLocationPreviewMap(
              origin: _clientLocation!,
              destination: _skipDestination ? null : _destinationLocation,
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
                if (!_skipDestination)
                  TextButton.icon(
                    onPressed: () => setState(() => _step = _stepDestination),
                    icon:
                        const Icon(Icons.edit_location_alt_outlined, size: 18),
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
          TaalaButton(
            label: AppStrings.requestHelp.tr(),
            onPressed: _submitting ? null : _submit,
            enabled: !_submitting,
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
