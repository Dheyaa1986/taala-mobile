import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_fab.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  PickedLocation? _clientLocation;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    var saved = await OrderLocationPrefs.readClient(getIt<SharedPref>());
    if (saved == null) {
      final current = await getIt<DeviceLocationService>().getCurrentLocation();
      if (current != null) {
        var picked = PickedLocation(
          latitude: current.latitude,
          longitude: current.longitude,
        );
        picked = await OrderLocationPrefs.ensureAddress(
          picked,
          getIt<ReverseGeocodingService>(),
        );
        await OrderLocationPrefs.saveClient(getIt<SharedPref>(), picked);
        saved = picked;
      }
    }
    if (!mounted) return;
    setState(() => _clientLocation = saved);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceProvidersCubit(
        repository: getIt<ProviderRepository>(),
      ),
      child: _ClientHomeBody(
        clientLocation: _clientLocation,
        onLocationLoaded: (location) {
          if (!mounted) return;
          setState(() => _clientLocation = location);
        },
      ),
    );
  }
}

class _ClientHomeBody extends StatefulWidget {
  const _ClientHomeBody({
    required this.clientLocation,
    required this.onLocationLoaded,
  });

  final PickedLocation? clientLocation;
  final ValueChanged<PickedLocation> onLocationLoaded;

  @override
  State<_ClientHomeBody> createState() => _ClientHomeBodyState();
}

class _ClientHomeBodyState extends State<_ClientHomeBody> {
  ServiceOrderModel? _activeOrder;
  final _activeOrderRefresh = getIt<ActiveOrderRefreshNotifier>();

  @override
  void initState() {
    super.initState();
    _activeOrderRefresh.addListener(_loadActiveOrder);
    _loadActiveOrder();
    _loadProvidersIfNeeded(widget.clientLocation);
  }

  @override
  void dispose() {
    _activeOrderRefresh.removeListener(_loadActiveOrder);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ClientHomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clientLocation != oldWidget.clientLocation) {
      _loadProvidersIfNeeded(widget.clientLocation);
    }
  }

  Future<void> _loadActiveOrder() async {
    final result = await getIt<ServiceOrderRepository>().getActiveOrder();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _activeOrder = null),
      (order) => setState(() => _activeOrder = order),
    );
  }

  void _loadProvidersIfNeeded(PickedLocation? location) {
    if (location == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServiceProvidersCubit>().loadNearestAvailable(
            latitude: location.latitude,
            longitude: location.longitude,
          );
    });
  }

  void _showActiveOrderBlockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.activeOrderBlockingSearch.tr())),
    );
  }

  Future<void> _openCreateOrder() async {
    await context.pushNamed(Routes.createServiceOrder);
    if (!mounted) return;
    final saved = await OrderLocationPrefs.readClient(getIt<SharedPref>());
    if (saved != null) {
      widget.onLocationLoaded(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveOrder = _activeOrder?.id != null;

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
      floatingActionButton: const SupportWhatsAppFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SingleChildScrollView(
        padding: REdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + context.safeBottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasActiveOrder) ...[
              YellowHighlightCard(
                isHighlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.activeOrderBlockingSearch.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    12.height,
                    CustomButton.filled(
                      text: AppStrings.openActiveOrder.tr(),
                      onTap: () => ServiceOrderNavigation.openDetail(
                        _activeOrder!.id!,
                        openChat: true,
                      ),
                    ),
                  ],
                ),
              ),
              20.height,
            ],
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
            24.height,
            CustomButton.filled(
              text: AppStrings.requestHelp.tr(),
              onTap: hasActiveOrder
                  ? _showActiveOrderBlockedMessage
                  : _openCreateOrder,
              enabled: !hasActiveOrder,
              height: 56.h,
            ),
            if (widget.clientLocation != null) ...[
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
                              child: ServiceProviderCard(
                                model: provider,
                                canStartOrder: !hasActiveOrder,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
