import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';
import 'package:taal/core/maps/widgets/taala_map_view.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';

class ProviderInAppNavigationArgs {
  const ProviderInAppNavigationArgs({
    required this.targetLatitude,
    required this.targetLongitude,
    this.targetTitle,
  });

  final double targetLatitude;
  final double targetLongitude;
  final String? targetTitle;
}

class ProviderInAppNavigationScreen extends StatefulWidget {
  const ProviderInAppNavigationScreen({super.key, required this.args});

  final ProviderInAppNavigationArgs args;

  @override
  State<ProviderInAppNavigationScreen> createState() =>
      _ProviderInAppNavigationScreenState();
}

class _ProviderInAppNavigationScreenState extends State<ProviderInAppNavigationScreen>
    with TaalaOfflineMapMixin {
  final _routing = getIt<TaalaRoutingService>();
  final _deviceLocation = getIt<DeviceLocationService>();

  LatLng? _providerPoint;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;
  int _cameraRevision = 0;
  Timer? _locationTimer;

  LatLng get _targetPoint => LatLng(
        widget.args.targetLatitude,
        widget.args.targetLongitude,
      );

  @override
  void initState() {
    super.initState();
    unawaited(refreshOfflineMapPath(
      widget.args.targetLatitude,
      widget.args.targetLongitude,
    ));
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_refreshLocation());
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _onMapReady() {
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _refreshLocation();
    if (!mounted) return;
    await _loadRoute();
  }

  Future<void> _refreshLocation() async {
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted || current == null) return;
    final point = LatLng(current.latitude, current.longitude);
    setState(() => _providerPoint = point);
    await _loadRoute();
  }

  Future<void> _loadRoute() async {
    final from = _providerPoint;
    if (from == null) return;

    setState(() => _loadingRoute = true);
    final route = await _routing.fetchDrivingRoute(from, _targetPoint);
    if (!mounted) return;
    setState(() {
      _routePoints = route;
      _loadingRoute = false;
    });
  }

  List<LatLng> _fitPoints(LatLng from) {
    return <LatLng>[from, _targetPoint, ..._routePoints];
  }

  @override
  Widget build(BuildContext context) {
    final provider = _providerPoint;
    final routePolyline = _routePoints.length >= 2
        ? _routePoints
        : provider != null
            ? [provider, _targetPoint]
            : <LatLng>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navigateInApp.tr()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TaalaMapView(
              initialCenter: _targetPoint,
              initialZoom: 14,
              onMapReady: _onMapReady,
              offlineMapPath: offlineMapPath,
              fitPoints: provider != null ? _fitPoints(provider) : null,
              cameraRevision: _cameraRevision,
              fitPadding: EdgeInsets.fromLTRB(48.w, 120.h, 48.w, 160.h),
              polylines: routePolyline.length >= 2
                  ? [
                      TaalaMapPolyline(
                        points: routePolyline,
                        color: AppColors.primaryColor,
                        width: 6,
                      ),
                    ]
                  : const [],
              markers: [
                if (provider != null)
                  TaalaMapMarker(
                    point: provider,
                    color: AppColors.primaryColor,
                    icon: Icons.local_shipping_rounded,
                    iconSize: 32,
                    livePulse: true,
                  ),
                TaalaMapMarker(
                  point: _targetPoint,
                  color: Colors.red,
                  icon: Icons.location_on,
                  iconSize: 40,
                ),
              ],
            ),
          ),
          if (_loadingRoute)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
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
            bottom: 120.h + context.safeBottomInset,
            child: FloatingActionButton(
              heroTag: 'provider_nav_gps',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, -2),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.args.targetTitle ?? AppStrings.navigateToClient.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  8.height,
                  Text(
                    AppStrings.inAppNavigationHint.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.commentColor,
                      height: 1.35,
                    ),
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
