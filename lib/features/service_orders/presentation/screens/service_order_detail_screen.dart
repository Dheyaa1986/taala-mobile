import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/alerts/app_alert_sound_service.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/google/google_maps_config.dart';
import 'package:taal/core/maps/provider_live_location_service.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/widgets/grouped_conversation_box.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/layout/bottom_safe_area.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';
import 'package:taal/features/service_orders/presentation/screens/provider_in_app_navigation_screen.dart';
import 'package:taal/features/service_orders/presentation/widgets/order_tracking_map.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/features/service_orders/presentation/widgets/service_order_location_summary.dart';

class ServiceOrderDetailScreen extends StatefulWidget {
  const ServiceOrderDetailScreen({
    super.key,
    required this.orderId,
    this.openChatOnStart = false,
  });

  final String orderId;
  final bool openChatOnStart;

  @override
  State<ServiceOrderDetailScreen> createState() =>
      _ServiceOrderDetailScreenState();
}

class _ServiceOrderDetailScreenState extends State<ServiceOrderDetailScreen> {
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();
  final _repository = getIt<ServiceOrderRepository>();
  final _scrollController = ScrollController();

  ServiceOrderModel? _order;
  ServiceOrderTrackingModel? _tracking;
  bool _loading = true;
  bool _sending = false;
  bool _isProvider = false;
  String? _myUserId;
  Timer? _trackingTimer;
  Timer? _messagesTimer;
  Timer? _deviceLocationTimer;
  double? _providerDeviceLat;
  double? _providerDeviceLng;
  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadTracking();
    });
    _messagesTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _messagesTimer?.cancel();
    _deviceLocationTimer?.cancel();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final prefs = getIt<SharedPref>();
    final isProvider =
        await prefs.get(key: PrefsKeys.isProviderAccount) == true;
    final profile = await getIt<ProfileRepository>().getMyProfile();
    if (!mounted) return;
    setState(() {
      _isProvider = isProvider;
      profile.fold((_) {}, (p) => _myUserId = p.id);
    });

    if (isProvider) {
      await ServiceOrderLocalStateHelper.markRead(widget.orderId);
    }
  }

  Future<void> _load({bool silent = false}) async {
    final result = await _repository.getOrder(widget.orderId);
    if (!mounted) return;
    result.fold(
      (error) {
        if (!silent) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message)),
          );
        }
      },
      (order) {
        if (silent) {
          final previousCount = _order?.messages.length ?? 0;
          final newCount = order.messages.length;
          if (newCount > previousCount) {
            final incoming = order.messages
                .skip(previousCount)
                .any((message) => message.senderId != _myUserId);
            if (incoming) {
              getIt<AppAlertSoundService>().play();
            }
          }

          final previousStatus = _order?.status;
          if (previousStatus != null &&
              previousStatus != order.status &&
              (order.status == 'cancelled' || order.status == 'completed')) {
            _handleTerminalStatus(order, remote: true);
            return;
          }
        }

        setState(() {
          _order = order;
          _loading = false;
        });
        _syncTripTracking(order);
        _persistHistory(order);
        if (!silent) {
          _loadTracking();
          if (widget.openChatOnStart) {
            _focusChat();
          }
        }
      },
    );
  }

  void _persistHistory(ServiceOrderModel order) {
    final myLines = order.messages
        .where((message) => message.senderId == _myUserId)
        .map(
          (message) => ConversationLine(
            text: message.message ?? '',
            time: message.createdAt,
          ),
        )
        .toList();
    final theirLines = order.messages
        .where((message) => message.senderId != _myUserId)
        .map(
          (message) => ConversationLine(
            text: message.message ?? '',
            time: message.createdAt,
          ),
        )
        .toList();

    if (myLines.isEmpty && theirLines.isEmpty) return;

    final title = _isProvider
        ? (order.clientName ?? AppStrings.serviceOrder.tr())
        : (order.providerName ?? order.serviceType?.name ?? AppStrings.serviceOrder.tr());

    ConversationHistoryHelper.save(
      ConversationHistoryEntry(
        id: 'order_${order.id}',
        type: 'order',
        title: title,
        myLines: myLines,
        theirLines: theirLines,
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<ConversationLine> _theirLines(ServiceOrderModel order) {
    return order.messages
        .where((message) => message.senderId != _myUserId)
        .map(
          (message) => ConversationLine(
            text: message.message ?? '',
            time: message.createdAt,
          ),
        )
        .toList();
  }

  List<ConversationLine> _myLines(ServiceOrderModel order) {
    return order.messages
        .where((message) => message.senderId == _myUserId)
        .map(
          (message) => ConversationLine(
            text: message.message ?? '',
            time: message.createdAt,
          ),
        )
        .toList();
  }

  Future<void> _loadTracking() async {
    final result = await _repository.getTracking(widget.orderId);
    if (!mounted) return;
    result.fold((_) {}, (tracking) {
      setState(() => _tracking = tracking);
    });
  }

  void _syncTripTracking(ServiceOrderModel order) {
    if (!_isProvider) return;
    final liveLocation = getIt<ProviderLiveLocationService>();
    if (order.status == 'accepted' || order.status == 'en_route') {
      if (!liveLocation.isTripTracking) {
        liveLocation.startTripTracking();
      }
      if (_deviceLocationTimer == null) {
        _startDeviceLocationUpdates();
      }
    } else {
      if (liveLocation.isTripTracking) {
        liveLocation.stopTripTracking();
      }
      _stopDeviceLocationUpdates();
    }
  }

  void _startDeviceLocationUpdates() {
    _deviceLocationTimer?.cancel();
    _refreshDeviceLocation();
    _deviceLocationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshDeviceLocation();
    });
  }

  void _stopDeviceLocationUpdates() {
    _deviceLocationTimer?.cancel();
    _deviceLocationTimer = null;
  }

  Future<void> _refreshDeviceLocation() async {
    final loc = await getIt<DeviceLocationService>().getCurrentLocation();
    if (!mounted || loc == null) return;
    setState(() {
      _providerDeviceLat = loc.latitude;
      _providerDeviceLng = loc.longitude;
    });
  }

  double? get _mapProviderLat {
    if (_isProvider && _providerDeviceLat != null) return _providerDeviceLat;
    return _tracking?.providerLatitude;
  }

  double? get _mapProviderLng {
    if (_isProvider && _providerDeviceLng != null) return _providerDeviceLng;
    return _tracking?.providerLongitude;
  }

  ({double lat, double lng, String? title})? _providerNavigationTarget(
    ServiceOrderModel order,
  ) {
    final toDestination = order.status == 'arrived' &&
        order.destinationLatitude != null &&
        order.destinationLongitude != null;
    if (toDestination) {
      return (
        lat: order.destinationLatitude!,
        lng: order.destinationLongitude!,
        title: order.destinationAddress ?? AppStrings.navigateToDestination.tr(),
      );
    }
    if (order.clientLatitude == null || order.clientLongitude == null) {
      return null;
    }
    return (
      lat: order.clientLatitude!,
      lng: order.clientLongitude!,
      title: order.clientName,
    );
  }

  Future<void> _openWazeNavigation(ServiceOrderModel order) async {
    final target = _providerNavigationTarget(order);
    if (target == null) return;

    await getIt<CustomLauncher>().openWazeDirections(
      destinationLat: target.lat,
      destinationLng: target.lng,
      destinationTitle: target.title,
      originLat: order.status == 'en_route' || order.status == 'arrived'
          ? _mapProviderLat
          : null,
      originLng: order.status == 'en_route' || order.status == 'arrived'
          ? _mapProviderLng
          : null,
    );
  }

  Future<void> _openExternalMaps(ServiceOrderModel order) async {
    if (_isProvider) {
      final target = _providerNavigationTarget(order);
      if (target == null) return;

      await getIt<CustomLauncher>().openDirections(
        destinationLat: target.lat,
        destinationLng: target.lng,
        destinationTitle: target.title,
        originLat: order.status == 'en_route' || order.status == 'arrived'
            ? _mapProviderLat
            : null,
        originLng: order.status == 'en_route' || order.status == 'arrived'
            ? _mapProviderLng
            : null,
      );
      return;
    }

    final providerLat = _mapProviderLat;
    final providerLng = _mapProviderLng;
    if (providerLat == null || providerLng == null) return;

    await getIt<CustomLauncher>().openDirections(
      destinationLat: providerLat,
      destinationLng: providerLng,
      destinationTitle: order.providerName,
    );
  }

  void _openInAppNavigation(ServiceOrderModel order) {
    if (!GoogleMapsConfig.isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.googleMapsRequired.tr())),
      );
      return;
    }

    final navigateToDestination = order.status == 'arrived' &&
        order.destinationLatitude != null &&
        order.destinationLongitude != null;

    final targetLat = navigateToDestination
        ? order.destinationLatitude!
        : order.clientLatitude;
    final targetLng = navigateToDestination
        ? order.destinationLongitude!
        : order.clientLongitude;

    if (targetLat == null || targetLng == null) return;

    final hasDestination = order.destinationLatitude != null &&
        order.destinationLongitude != null;

    context.pushNamed(
      Routes.providerInAppNavigation,
      pathParameters: {'id': widget.orderId},
      extra: ProviderInAppNavigationArgs(
        targetLatitude: targetLat,
        targetLongitude: targetLng,
        targetTitle: navigateToDestination
            ? AppStrings.navigateToDestination.tr()
            : AppStrings.navigateToClient.tr(),
        orderId: widget.orderId,
        isBreakdownLeg: !navigateToDestination && hasDestination,
        destinationLatitude: order.destinationLatitude,
        destinationLongitude: order.destinationLongitude,
        destinationTitle: order.destinationAddress,
      ),
    );
  }

  bool _canOpenInAppNavigation(ServiceOrderModel order) {
    if (!_isProvider) return false;
    if (order.status == 'arrived') {
      return order.destinationLatitude != null &&
          order.destinationLongitude != null;
    }
    return order.clientLatitude != null && order.clientLongitude != null;
  }

  bool _canOpenExternalMaps(ServiceOrderModel order) {
    if (_isProvider) return _canOpenInAppNavigation(order);
    return _mapProviderLat != null && _mapProviderLng != null;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final result = await _repository.sendMessage(
      orderId: widget.orderId,
      message: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        _messageController.clear();
        setState(() => _order = order);
      },
    );
  }

  bool _isPriceLocked(ServiceOrderModel order) => order.priceLockedAt != null;

  bool _canClientCancelBecauseProviderNotMoving(ServiceOrderModel order) =>
      !_isProvider &&
      _isPriceLocked(order) &&
      order.status == 'accepted' &&
      order.providerEnRouteAt == null;

  Future<void> _confirmCancelOrder() async {
    final order = _order;
    if (order != null &&
        order.priceLockedAt != null &&
        order.providerEnRouteAt != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.cancelOrderActiveHint.tr())),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.cancelOrder.tr()),
        content: Text(
          order != null && _canClientCancelBecauseProviderNotMoving(order)
              ? AppStrings.cancelOnlyIfProviderNotMoving.tr()
              : AppStrings.cancelOrderConfirm.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.cancelOrder.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _updateStatus('cancelled');
    }
  }

  Future<bool> _confirmActionDialog({
    required String titleKey,
    required String bodyKey,
    required String confirmKey,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titleKey.tr()),
        content: Text(bodyKey.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmKey.tr()),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _confirmClientReady() async {
    final loc = await getIt<DeviceLocationService>().getCurrentLocation();
    final result = await _repository.confirmClientReady(
      orderId: widget.orderId,
      clientLatitude: loc?.latitude,
      clientLongitude: loc?.longitude,
    );
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) => setState(() => _order = order),
    );
  }

  Future<void> _performAction(String action, {bool terminal = true}) async {
    final result = await _repository.performAction(
      orderId: widget.orderId,
      action: action,
    );
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        setState(() => _order = order);
        if (terminal) {
          _handleTerminalStatus(order, remote: false);
        }
      },
    );
  }

  Future<void> _updateStatus(String status, {double? agreedPrice}) async {
    final result = await _repository.updateStatus(
      orderId: widget.orderId,
      status: status,
      agreedPrice: agreedPrice,
    );
    if (!mounted) return;
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        setState(() => _order = order);
        _syncTripTracking(order);
        if (_isProvider && status == 'accepted') {
          _focusChat();
        }
        if (status == 'completed' || status == 'cancelled') {
          _handleTerminalStatus(order, remote: false);
        }
      },
    );
  }

  void _handleTerminalStatus(ServiceOrderModel order, {required bool remote}) {
    getIt<ActiveOrderRefreshNotifier>().notifyChanged();
    if (!mounted) return;

    if (remote && !_isProvider && order.status == 'cancelled') {
      final reason = order.cancellationReason;
      final message = reason == 'vehicle_breakdown'
          ? AppStrings.orderCancelledReorderHint.tr()
          : reason == 'problem_solved'
              ? AppStrings.orderProblemSolvedByClient.tr()
              : AppStrings.orderCancelledByProvider.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    if (context.mounted) {
      context.pop();
    }
  }

  void _focusChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      _messageFocusNode.requestFocus();
    });
  }

  Future<void> _acceptOrder() async {
    await _sendMessageWithText(AppStrings.providerAcceptedChat.tr());
    _focusChat();
  }

  Future<void> _sendMessageWithText(String text) async {
    setState(() => _sending = true);
    final result = await _repository.sendMessage(
      orderId: widget.orderId,
      message: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) => setState(() => _order = order),
    );
  }

  Future<void> _proposePrice() async {
    final order = _order;
    final priceController = TextEditingController();
    final proposed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.proposePrice.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (order != null) ...[
              ServiceOrderLocationSummary(order: order, tracking: _tracking),
              12.height,
            ],
            CustomTextField(
              controller: priceController,
              label: AppStrings.agreedPrice.tr(),
              hint: AppStrings.enterAgreedPrice.tr(),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.sendPrice.tr()),
          ),
        ],
      ),
    );
    if (proposed == true) {
      final price = double.tryParse(priceController.text.trim());
      if (price == null) return;
      final result = await _repository.proposePrice(
        orderId: widget.orderId,
        agreedPrice: price,
      );
      if (!mounted) return;
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        ),
        (order) => setState(() => _order = order),
      );
    }
    priceController.dispose();
  }

  Future<void> _markArrivedAtBreakdown(ServiceOrderModel order) async {
    await _updateStatus('arrived');
    if (!mounted) return;
    await _openDestinationNavigationAfterArrival();
  }

  Future<void> _openDestinationNavigationAfterArrival() async {
    final updated = _order;
    if (updated == null || !mounted) return;

    final hasDestination = updated.destinationLatitude != null &&
        updated.destinationLongitude != null;
    if (!hasDestination) return;

    if (GoogleMapsConfig.isEnabled && _canOpenInAppNavigation(updated)) {
      _openInAppNavigation(updated);
      return;
    }

    await _openWazeNavigation(updated);
  }

  Future<void> _approveOrder() async {
    final order = _order;
    if (order?.agreedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.waitForProviderPrice.tr())),
      );
      return;
    }

    await _updateStatus('accepted');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.confirmStillNeedServiceHint.tr())),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'accepted':
        return AppStrings.orderStatusAccepted.tr();
      case 'en_route':
        return AppStrings.orderStatusEnRoute.tr();
      case 'arrived':
        return AppStrings.orderStatusArrived.tr();
      case 'completed':
        return AppStrings.orderStatusCompleted.tr();
      case 'cancelled':
        return AppStrings.orderStatusCancelled.tr();
      default:
        return AppStrings.orderStatusPending.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final canChat = order?.status != 'cancelled' && order?.status != 'completed';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppStrings.serviceOrder.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: REdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                if (order != null)
                  Container(
                    width: double.infinity,
                    margin: REdgeInsets.all(12),
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isProvider
                              ? (order.clientName ?? '')
                              : (order.providerName ?? ''),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                        4.height,
                        Text(
                          order.serviceType?.name ?? order.description ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: TaalaTokens.of(context).textSecondary,
                          ),
                        ),
                        6.height,
                        Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        8.height,
                        ServiceOrderLocationSummary(
                          order: order,
                          tracking: _tracking,
                        ),
                        if (order.agreedPrice != null) ...[
                          8.height,
                          Text(
                            '${AppStrings.proposedPrice.tr()}: ${order.agreedPrice}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (_tracking != null &&
                    order?.status != 'pending' &&
                    (_tracking!.distanceKm != null ||
                        _tracking!.etaMinutes != null))
                  Container(
                    width: double.infinity,
                    margin: REdgeInsets.symmetric(horizontal: 12),
                    padding: REdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.trackArrival.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                        6.height,
                        Text(
                          [
                            if (_tracking!.distanceKm != null)
                              '${_tracking!.distanceKm!.toStringAsFixed(2)} ${AppStrings.distanceKm.tr()}',
                            if (_tracking!.etaMinutes != null)
                              '${_tracking!.etaMinutes} ${AppStrings.minutes.tr()}',
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order != null &&
                    order.clientLatitude != null &&
                    order.clientLongitude != null &&
                    (order.status == 'pending' ||
                        order.status == 'accepted' ||
                        order.status == 'en_route' ||
                        order.status == 'arrived'))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          order.status == 'pending'
                              ? AppStrings.requestLocationOnMap.tr()
                              : _isProvider
                                  ? AppStrings.clientLocationOnMap.tr()
                                  : AppStrings.trackProviderOnMap.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                        8.height,
                        OrderTrackingMap(
                          clientLatitude: order.clientLatitude!,
                          clientLongitude: order.clientLongitude!,
                          providerLatitude: _mapProviderLat,
                          providerLongitude: _mapProviderLng,
                          destinationLatitude: order.destinationLatitude,
                          destinationLongitude: order.destinationLongitude,
                        ),
                      ],
                    ),
                  ),
                if (_isProvider &&
                    order != null &&
                    order.status == 'accepted' &&
                    order.clientReadyAt == null)
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.waitForClientReady.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: TaalaTokens.of(context).textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                if (_isProvider &&
                    order != null &&
                    _canOpenInAppNavigation(order) &&
                    ((order.status == 'accepted' && order.clientReadyAt != null) ||
                        order.status == 'en_route' ||
                        order.status == 'arrived'))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TaalaButton(
                          label: AppStrings.departInApp.tr(),
                          onPressed: () async {
                            if (order.status == 'accepted') {
                              await _updateStatus('en_route');
                              if (!mounted) return;
                            }
                            final current = _order;
                            if (current != null) _openInAppNavigation(current);
                          },
                        ),
                        8.height,
                        TaalaButton(
                          label: AppStrings.openInWaze.tr(),
                          variant: TaalaButtonVariant.secondary,
                          onPressed: () => _openWazeNavigation(order),
                        ),
                        if (order.status == 'en_route') ...[
                          8.height,
                          TaalaButton(
                            label: AppStrings.arrived.tr(),
                            onPressed: () =>
                                unawaited(_markArrivedAtBreakdown(order)),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (_isProvider &&
                    order != null &&
                    _isPriceLocked(order) &&
                    (order.status == 'accepted' ||
                        order.status == 'en_route' ||
                        order.status == 'arrived'))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TaalaButton(
                      label: AppStrings.vehicleBreakdown.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () async {
                        final ok = await _confirmActionDialog(
                          titleKey: AppStrings.vehicleBreakdown,
                          bodyKey: AppStrings.vehicleBreakdownConfirm,
                          confirmKey: AppStrings.vehicleBreakdown,
                        );
                        if (ok && mounted) {
                          await _performAction('vehicle_breakdown');
                        }
                      },
                    ),
                  ),
                if (_isProvider &&
                    order != null &&
                    (order.status == 'en_route' || order.status == 'arrived'))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.clientNotFound.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () async {
                        final ok = await _confirmActionDialog(
                          titleKey: AppStrings.clientNotFound,
                          bodyKey: AppStrings.clientNotFoundConfirm,
                          confirmKey: AppStrings.clientNotFound,
                        );
                        if (ok && mounted) {
                          await _performAction('client_not_found');
                        }
                      },
                    ),
                  ),
                8.height,
                if (_isProvider && order?.status == 'pending') ...[
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.proposePrice.tr(),
                      onPressed: _proposePrice,
                    ),
                  ),
                  8.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.acceptAndChat.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: _acceptOrder,
                    ),
                  ),
                  8.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.rejectOrder.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () => _updateStatus('cancelled'),
                    ),
                  ),
                ],
                if (!_isProvider &&
                    order != null &&
                    order.status != 'pending' &&
                    _canOpenExternalMaps(order))
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.openInMapApp.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () => _openExternalMaps(order),
                    ),
                  ),
                if (!_isProvider && order?.status == 'pending') ...[
                  if (order?.agreedPrice == null) ...[
                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        AppStrings.waitForProviderPrice.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: TaalaTokens.of(context).textSecondary,
                        ),
                      ),
                    ),
                    12.height,
                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 12),
                      child: TaalaButton(
                        label: AppStrings.cancelOrder.tr(),
                        variant: TaalaButtonVariant.secondary,
                        onPressed: _confirmCancelOrder,
                      ),
                    ),
                  ],
                  if (order?.agreedPrice != null) ...[
                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${AppStrings.proposedPrice.tr()}: ${order!.agreedPrice}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    12.height,
                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TaalaButton(
                              label: AppStrings.cancelOrder.tr(),
                              variant: TaalaButtonVariant.secondary,
                              onPressed: _confirmCancelOrder,
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: TaalaButton(
                              label: AppStrings.approveOrder.tr(),
                              onPressed: _approveOrder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                if (!_isProvider &&
                    order != null &&
                    _isPriceLocked(order) &&
                    order.status == 'accepted' &&
                    order.clientReadyAt == null) ...[
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.confirmStillNeedServiceHint.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: TaalaTokens.of(context).textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  12.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.confirmStillNeedService.tr(),
                      onPressed: _confirmClientReady,
                    ),
                  ),
                  8.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.problemSolved.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () async {
                        final ok = await _confirmActionDialog(
                          titleKey: AppStrings.problemSolved,
                          bodyKey: AppStrings.problemSolvedConfirm,
                          confirmKey: AppStrings.problemSolved,
                        );
                        if (ok && mounted) {
                          await _performAction('problem_solved');
                        }
                      },
                    ),
                  ),
                ],
                if (!_isProvider &&
                    order != null &&
                    _canClientCancelBecauseProviderNotMoving(order)) ...[
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.cancelOnlyIfProviderNotMoving.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: TaalaTokens.of(context).textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  12.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.cancelOrder.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: _confirmCancelOrder,
                    ),
                  ),
                  8.height,
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.problemSolved.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () async {
                        final ok = await _confirmActionDialog(
                          titleKey: AppStrings.problemSolved,
                          bodyKey: AppStrings.problemSolvedConfirm,
                          confirmKey: AppStrings.problemSolved,
                        );
                        if (ok && mounted) {
                          await _performAction('problem_solved');
                        }
                      },
                    ),
                  ),
                ],
                if (!_isProvider &&
                    order != null &&
                    _isPriceLocked(order) &&
                    (order.status == 'accepted' || order.status == 'en_route') &&
                    order.clientReadyAt != null &&
                    order.providerEnRouteAt != null) ...[
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.problemSolved.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () async {
                        final ok = await _confirmActionDialog(
                          titleKey: AppStrings.problemSolved,
                          bodyKey: AppStrings.problemSolvedConfirm,
                          confirmKey: AppStrings.problemSolved,
                        );
                        if (ok && mounted) {
                          await _performAction('problem_solved');
                        }
                      },
                    ),
                  ),
                ],
                if (!_isProvider && order?.status == 'arrived')
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 12),
                    child: TaalaButton(
                      label: AppStrings.completeOrder.tr(),
                      onPressed: () => _updateStatus('completed'),
                    ),
                  ),
                Padding(
                  padding: REdgeInsets.all(12),
                  child: Column(
                    children: [
                      GroupedConversationBox(
                        title: _isProvider
                            ? (order?.clientName ?? AppStrings.incomingReplies.tr())
                            : (order?.providerName ?? AppStrings.incomingReplies.tr()),
                        lines: order == null ? const [] : _theirLines(order),
                        isMine: false,
                      ),
                      GroupedConversationBox(
                        title: AppStrings.you.tr(),
                        lines: order == null ? const [] : _myLines(order),
                        isMine: true,
                      ),
                    ],
                  ),
                ),
                      ],
                    ),
                  ),
                ),
                if (canChat)
                  BottomSafeArea(
                    includeKeyboard: true,
                    extra: 8,
                    child: Padding(
                      padding: REdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _messageController,
                            hint: AppStrings.writeMessage.tr(),
                            focusNode: _messageFocusNode,
                          ),
                        ),
                        8.width,
                        IconButton(
                          onPressed: _sending ? null : _sendMessage,
                          icon: _sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                    ),
                  ),
              ],
            ),
    );
  }
}
