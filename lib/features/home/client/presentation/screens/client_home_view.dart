import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_fab.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/service_provider_card.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/core/guest/guest_action_guard.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';
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
  List<ServiceOrderModel> _liveOrders = [];
  final _activeOrderRefresh = getIt<ActiveOrderRefreshNotifier>();
  late final AppAlertMonitor _alertMonitor;
  bool _isGuest = false;

  bool _isBlockingStatus(String? status) =>
      status == 'accepted' || status == 'en_route' || status == 'arrived';

  bool _isLiveStatus(String? status) =>
      status == 'pending' || _isBlockingStatus(status);

  bool get _hasBlockingOrder =>
      _liveOrders.any((order) => _isBlockingStatus(order.status));

  @override
  void initState() {
    super.initState();
    _alertMonitor = getIt<AppAlertMonitor>();
    _activeOrderRefresh.addListener(_loadLiveOrders);
    _alertMonitor.ordersRefreshTick.addListener(_loadLiveOrders);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final isGuest = await GuestSessionHelper.isGuestBrowsing();
    if (!mounted) return;
    setState(() => _isGuest = isGuest);
    if (!isGuest) {
      _loadLiveOrders();
    }
    _loadProvidersIfNeeded(widget.clientLocation);
  }

  @override
  void dispose() {
    _activeOrderRefresh.removeListener(_loadLiveOrders);
    _alertMonitor.ordersRefreshTick.removeListener(_loadLiveOrders);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ClientHomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clientLocation != oldWidget.clientLocation) {
      _loadProvidersIfNeeded(widget.clientLocation);
    }
  }

  Future<void> _loadLiveOrders() async {
    final result = await getIt<ServiceOrderRepository>().getMyOrders(limit: 30);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _liveOrders = []),
      (orders) => setState(
        () => _liveOrders =
            orders.where((order) => _isLiveStatus(order.status)).toList(),
      ),
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
    if (!await GuestActionGuard.ensureRegistered(context)) return;
    if (!mounted) return;
    await context.pushNamed(Routes.createServiceOrder);
    if (!mounted) return;
    await _loadLiveOrders();
    final saved = await OrderLocationPrefs.readClient(getIt<SharedPref>());
    if (saved != null) {
      widget.onLocationLoaded(saved);
    }
  }

  Future<void> _openLiveOrder(
    ServiceOrderModel order, {
    bool openChat = false,
  }) async {
    final id = order.id;
    if (id == null) return;
    await context.pushNamed(
      Routes.serviceOrderDetail,
      pathParameters: {'id': id},
      extra: openChat,
    );
    if (!mounted) return;
    await _loadLiveOrders();
  }

  String _liveOrderTitle(ServiceOrderModel order) {
    if (order.status == 'pending') {
      if (order.agreedPrice == null) {
        return AppStrings.waitForProviderPrice.tr();
      }
      return '${AppStrings.proposedPrice.tr()}: ${order.agreedPrice}';
    }
    if (order.status == 'en_route' || order.status == 'arrived') {
      return AppStrings.trackProviderOnMap.tr();
    }
    return AppStrings.approveOrderMapHint.tr();
  }

  String _liveOrderAction(ServiceOrderModel order) {
    if (order.status == 'pending' && order.agreedPrice != null) {
      return AppStrings.approveOrder.tr();
    }
    if (order.status == 'pending') {
      return AppStrings.openActiveOrder.tr();
    }
    if (order.status == 'arrived') {
      return AppStrings.completeOrder.tr();
    }
    return AppStrings.trackLiveOrder.tr();
  }

  @override
  Widget build(BuildContext context) {
    final hasBlockingOrder = _hasBlockingOrder;
    final tokens = TaalaTokens.of(context);

    return Scaffold(
      appBar: CustomAppBar.langAppBar(
        showProfileIcon: true,
        title: AppStrings.home.tr(),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: AppStrings.myServiceOrders.tr(),
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () async {
              if (!await GuestActionGuard.ensureRegistered(context)) return;
              if (!context.mounted) return;
              context.pushNamed(Routes.serviceOrders);
            },
          ),
        ],
      ),
      floatingActionButton:
          _isGuest ? null : const SupportWhatsAppFab(),
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
            if (_liveOrders.isNotEmpty && !_isGuest) ...[
              ..._liveOrders.map(
                (order) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: YellowHighlightCard(
                    isHighlighted: true,
                    onTap: () => _openLiveOrder(
                      order,
                      openChat: order.status != 'pending',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          order.providerName ??
                              order.serviceType?.name ??
                              AppStrings.serviceOrder.tr(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                        ),
                        6.height,
                        Text(
                          _liveOrderTitle(order),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: tokens.textSecondary,
                                    height: 1.4,
                                  ),
                        ),
                        12.height,
                        TaalaButton(
                          label: _liveOrderAction(order),
                          onPressed: () => _openLiveOrder(
                            order,
                            openChat: order.status != 'pending' ||
                                order.agreedPrice != null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              8.height,
            ],
            Text(
              AppStrings.clientHomeWelcome.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
            ),
            8.height,
            Text(
              AppStrings.clientHomeSubtitle.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    height: 1.5,
                  ),
            ),
            24.height,
            TaalaButton(
              label: AppStrings.requestHelp.tr(),
              onPressed: hasBlockingOrder
                  ? _showActiveOrderBlockedMessage
                  : _openCreateOrder,
              enabled: !hasBlockingOrder,
            ),
            if (widget.clientLocation != null) ...[
              24.height,
              Text(
                AppStrings.nearestProviders.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
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
                      ApiErrorMessage.resolve(state.error),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.error,
                          ),
                    );
                  }
                  if (state is ServiceProvidersLoaded &&
                      state.serviceProviders.isEmpty) {
                    return Text(
                      AppStrings.noProvidersNearby.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
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
                                canStartOrder: !hasBlockingOrder,
                                browseOnly: _isGuest,
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
