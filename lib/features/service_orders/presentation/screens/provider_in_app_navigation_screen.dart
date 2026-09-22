import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/design_system/tokens/taala_shadows.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/navigation/navigation_geometry.dart';
import 'package:taal/core/maps/navigation/navigation_tts_service.dart';
import 'package:taal/core/maps/navigation/route_guidance_controller.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/google_navigation_map.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';

class ProviderInAppNavigationArgs {
  const ProviderInAppNavigationArgs({
    required this.targetLatitude,
    required this.targetLongitude,
    this.targetTitle,
    this.orderId,
    this.isBreakdownLeg = false,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationTitle,
  });

  final double targetLatitude;
  final double targetLongitude;
  final String? targetTitle;
  final String? orderId;
  final bool isBreakdownLeg;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? destinationTitle;

  bool get hasDestinationLeg =>
      destinationLatitude != null && destinationLongitude != null;
}

class ProviderInAppNavigationScreen extends StatefulWidget {
  const ProviderInAppNavigationScreen({super.key, required this.args});

  final ProviderInAppNavigationArgs args;

  @override
  State<ProviderInAppNavigationScreen> createState() =>
      _ProviderInAppNavigationScreenState();
}

class _ProviderInAppNavigationScreenState extends State<ProviderInAppNavigationScreen> {
  final _routing = getIt<TaalaRoutingService>();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _tts = NavigationTtsService();
  late final RouteGuidanceController _guidance = RouteGuidanceController(_tts);

  LatLng? _providerPoint;
  double? _heading;
  TaalaNavigationRoute? _route;
  RouteGuidanceSnapshot _guidanceSnapshot = RouteGuidanceSnapshot.idle;
  bool _loadingRoute = false;
  bool _routeFailed = false;
  bool _navigationActive = false;
  int _cameraRevision = 0;
  Timer? _locationTimer;
  DateTime? _lastRerouteAt;
  late LatLng _targetPoint;
  late String? _targetTitle;
  bool _breakdownLegComplete = false;
  bool _transitioningToDestination = false;

  @override
  void initState() {
    super.initState();
    _targetPoint = LatLng(
      widget.args.targetLatitude,
      widget.args.targetLongitude,
    );
    _targetTitle = widget.args.targetTitle;
    unawaited(_tts.initialize());
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_refreshLocation());
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _guidance.stop();
    unawaited(_tts.stop());
    super.dispose();
  }

  void _onMapReady() {
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _refreshLocation(updateRoute: false);
    if (!mounted) return;
    await _loadRoute(startNavigationAfter: true);
  }

  Future<void> _refreshLocation({bool updateRoute = true}) async {
    final reading = await _deviceLocation.getNavigationReading();
    if (!mounted || reading == null) return;

    final point = LatLng(reading.latitude, reading.longitude);
    setState(() {
      _providerPoint = point;
      if (reading.hasValidHeading) {
        _heading = reading.heading;
      }
    });

    if (!_navigationActive &&
        _route == null &&
        !_loadingRoute &&
        !_routeFailed) {
      unawaited(_loadRoute(startNavigationAfter: true));
      return;
    }

    if (_navigationActive) {
      final snapshot = _guidance.updatePosition(point);
      if (snapshot.arrived &&
          widget.args.isBreakdownLeg &&
          widget.args.hasDestinationLeg &&
          !_breakdownLegComplete) {
        unawaited(_proceedToDestinationLeg());
        return;
      }
      if (snapshot.offRoute && updateRoute && _canReroute()) {
        await _loadRoute(startNavigationAfter: true);
        return;
      }
      if (!mounted) return;
      setState(() => _guidanceSnapshot = snapshot);
      setState(() => _cameraRevision++);
    }
  }

  Future<void> _proceedToDestinationLeg() async {
    if (_breakdownLegComplete || _transitioningToDestination) return;
    _transitioningToDestination = true;

    final orderId = widget.args.orderId;
    if (orderId != null) {
      await getIt<ServiceOrderRepository>().updateStatus(
        orderId: orderId,
        status: 'arrived',
      );
    }

    if (!mounted) return;

    _breakdownLegComplete = true;
    _guidance.stop();
    setState(() {
      _targetPoint = LatLng(
        widget.args.destinationLatitude!,
        widget.args.destinationLongitude!,
      );
      _targetTitle =
          widget.args.destinationTitle ?? AppStrings.navigateToDestination.tr();
      _route = null;
      _navigationActive = false;
      _guidanceSnapshot = RouteGuidanceSnapshot.idle;
      _cameraRevision++;
    });

    _transitioningToDestination = false;
    await _loadRoute(startNavigationAfter: true);
  }

  bool _canReroute() {
    final last = _lastRerouteAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= const Duration(seconds: 15);
  }

  Future<void> _loadRoute({required bool startNavigationAfter}) async {
    final from = _providerPoint;
    if (from == null) return;

    setState(() {
      _loadingRoute = true;
      _routeFailed = false;
    });

    final route = await _routing.fetchNavigationRoute(from, _targetPoint);
    if (!mounted) return;

    if (route == null || !route.isValid) {
      setState(() {
        _route = null;
        _loadingRoute = false;
        _routeFailed = true;
      });
      return;
    }

    _lastRerouteAt = DateTime.now();
    _guidance.setRoute(route);

    setState(() {
      _route = route;
      _loadingRoute = false;
      _routeFailed = false;
    });

    if (startNavigationAfter) {
      _startNavigation();
    }
  }

  void _startNavigation() {
    if (_route == null || _providerPoint == null) return;
    _guidance.start();
    final snapshot = _providerPoint == null
        ? RouteGuidanceSnapshot.idle
        : _guidance.updatePosition(_providerPoint!);
    setState(() {
      _navigationActive = true;
      _guidanceSnapshot = snapshot;
      _cameraRevision++;
    });
  }

  String _statusText() {
    if (_loadingRoute) return AppStrings.navigationBuildingRoute.tr();
    if (_routeFailed) return AppStrings.navigationRouteFailed.tr();
    if (_guidanceSnapshot.arrived) return AppStrings.navigationArrived.tr();
    if (_navigationActive) return AppStrings.navigationActive.tr();
    if (_route != null) return AppStrings.navigationRouteReady.tr();
    if (_providerPoint != null) {
      return AppStrings.navigationBuildingRoute.tr();
    }
    return AppStrings.navigationGpsRequired.tr();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _providerPoint;
    final routePoints = _route?.points ?? const <LatLng>[];
    final routePolyline =
        routePoints.length >= 2 ? routePoints : const <LatLng>[];

    final remainingDistance = _guidanceSnapshot.remainingDistanceMeters;
    final remainingMinutes =
        formatNavigationDurationMinutes(_guidanceSnapshot.remainingDurationSeconds);
    final instruction = _guidanceSnapshot.currentInstruction;

    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.departInApp.tr()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleNavigationMap(
              target: _targetPoint,
              provider: provider,
              routePoints: routePolyline,
              followNavigation: _navigationActive,
              bearing: _heading,
              cameraRevision: _cameraRevision,
              onMapReady: _onMapReady,
            ),
          ),
          if (_loadingRoute)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: TaalaShadows.soft(brightness),
                ),
                child: Padding(
                  padding: REdgeInsets.all(8),
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 12.w,
            bottom: 180.h + context.safeBottomInset,
            child: FloatingActionButton(
              heroTag: 'provider_nav_gps',
              backgroundColor: tokens.surface,
              foregroundColor: tokens.primary,
              onPressed: () {
                if (_providerPoint != null) {
                  setState(() => _cameraRevision++);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: REdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + context.safeBottomInset,
              ),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                boxShadow: TaalaShadows.soft(brightness),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _targetTitle ?? AppStrings.navigateToClient.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                  ),
                  8.height,
                  if (_navigationActive && instruction.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.turn_right,
                          color: tokens.primary,
                          size: 28.r,
                        ),
                        8.width,
                        Expanded(
                          child: Text(
                            instruction,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.height,
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.straighten,
                          label: formatNavigationDistance(remainingDistance),
                        ),
                        8.width,
                        _InfoChip(
                          icon: Icons.schedule,
                          label: AppStrings.navigationRemainingMinutes.tr(
                            namedArgs: {
                              'minutes': '$remainingMinutes',
                            },
                          ),
                        ),
                      ],
                    ),
                    8.height,
                  ],
                  Text(
                    _statusText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                          height: 1.35,
                        ),
                  ),
                  if (!_navigationActive && _route != null) ...[
                    12.height,
                    FilledButton.icon(
                      onPressed: _startNavigation,
                      style: FilledButton.styleFrom(
                        backgroundColor: tokens.primary,
                        foregroundColor: tokens.onPrimary,
                      ),
                      icon: const Icon(Icons.navigation),
                      label: Text(AppStrings.navigationStart.tr()),
                    ),
                  ],
                  if (_routeFailed) ...[
                    12.height,
                    OutlinedButton.icon(
                      onPressed: () => unawaited(
                        _loadRoute(startNavigationAfter: false),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.navigationRecenter.tr()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.r, color: tokens.primary),
          6.width,
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.primary,
                ),
          ),
        ],
      ),
    );
  }
}
