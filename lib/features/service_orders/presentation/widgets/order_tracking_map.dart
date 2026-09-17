import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';
import 'package:taal/core/maps/widgets/taala_map_view.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';

class OrderTrackingMap extends StatefulWidget {
  const OrderTrackingMap({
    super.key,
    required this.clientLatitude,
    required this.clientLongitude,
    this.providerLatitude,
    this.providerLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.expandToFill = false,
    this.height,
    this.followProvider = true,
  });

  final double clientLatitude;
  final double clientLongitude;
  final double? providerLatitude;
  final double? providerLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final bool expandToFill;
  final double? height;
  final bool followProvider;

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap>
    with TaalaOfflineMapMixin {
  final _routing = getIt<TaalaRoutingService>();
  List<LatLng> _providerRoutePoints = [];
  List<LatLng> _destinationRoutePoints = [];
  bool _loadingRoute = false;
  LatLng? _lastRouteFrom;

  @override
  void initState() {
    super.initState();
    unawaited(refreshOfflineMapPath(
      widget.clientLatitude,
      widget.clientLongitude,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadRoutes());
    });
  }

  @override
  void didUpdateWidget(covariant OrderTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final providerChanged =
        oldWidget.providerLatitude != widget.providerLatitude ||
            oldWidget.providerLongitude != widget.providerLongitude;
    final destinationChanged =
        oldWidget.destinationLatitude != widget.destinationLatitude ||
            oldWidget.destinationLongitude != widget.destinationLongitude;
    if (providerChanged || destinationChanged) {
      unawaited(_loadRoutes());
    }
  }

  LatLng get _clientPoint =>
      LatLng(widget.clientLatitude, widget.clientLongitude);

  LatLng? get _providerPoint {
    if (widget.providerLatitude == null || widget.providerLongitude == null) {
      return null;
    }
    return LatLng(widget.providerLatitude!, widget.providerLongitude!);
  }

  LatLng? get _destinationPoint {
    if (widget.destinationLatitude == null ||
        widget.destinationLongitude == null) {
      return null;
    }
    return LatLng(widget.destinationLatitude!, widget.destinationLongitude!);
  }

  bool _shouldRefetchRoute(LatLng from) {
    if (_lastRouteFrom == null) return true;
    const distance = Distance();
    return distance(_lastRouteFrom!, from) > 80;
  }

  Future<void> _loadRoutes() async {
    final provider = _providerPoint;
    final destination = _destinationPoint;
    if (provider == null && destination == null) {
      if (mounted) {
        setState(() {
          _providerRoutePoints = [];
          _destinationRoutePoints = [];
          _loadingRoute = false;
        });
      }
      return;
    }

    setState(() => _loadingRoute = true);

    List<LatLng> providerRoute = [];
    List<LatLng> destinationRoute = [];

    if (provider != null && _shouldRefetchRoute(provider)) {
      providerRoute = await _routing.fetchDrivingRoute(provider, _clientPoint);
    } else if (provider != null) {
      providerRoute = _providerRoutePoints;
    }

    if (destination != null) {
      destinationRoute =
          await _routing.fetchDrivingRoute(_clientPoint, destination);
    }

    if (!mounted) return;
    setState(() {
      if (provider != null && _shouldRefetchRoute(provider)) {
        _providerRoutePoints = providerRoute;
        _lastRouteFrom = provider;
      }
      _destinationRoutePoints = destinationRoute;
      _loadingRoute = false;
    });
  }

  List<LatLng> _fitPoints() {
    final provider = _providerPoint;
    final destination = _destinationPoint;
    final points = <LatLng>[_clientPoint];
    if (provider != null) points.add(provider);
    if (destination != null) points.add(destination);
    if (_providerRoutePoints.isNotEmpty) points.addAll(_providerRoutePoints);
    if (_destinationRoutePoints.isNotEmpty) {
      points.addAll(_destinationRoutePoints);
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final provider = _providerPoint;
    final destination = _destinationPoint;
    final providerPolyline = _providerRoutePoints.isNotEmpty
        ? _providerRoutePoints
        : provider != null
            ? [provider, _clientPoint]
            : <LatLng>[];

    final polylines = <TaalaMapPolyline>[
      if (providerPolyline.length >= 2)
        TaalaMapPolyline(
          points: providerPolyline,
          color: AppColors.primaryColor,
          width: 5,
        ),
      if (_destinationRoutePoints.length >= 2)
        TaalaMapPolyline(
          points: _destinationRoutePoints,
          color: Colors.green.shade700,
          width: 4,
          dashed: true,
        ),
    ];

    final markers = <TaalaMapMarker>[
      TaalaMapMarker(
        point: _clientPoint,
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
        iconSize: 34,
      ),
      if (provider != null)
        TaalaMapMarker(
          point: provider,
          color: AppColors.primaryColor,
          icon: Icons.local_shipping_rounded,
          iconSize: 30,
          livePulse: true,
        ),
      if (destination != null)
        TaalaMapMarker(
          point: destination,
          color: Colors.green.shade700,
          icon: Icons.flag_rounded,
          iconSize: 34,
        ),
    ];

    final mapStack = Stack(
      children: [
        TaalaMapView(
          initialCenter: _clientPoint,
          initialZoom: 14,
          markers: markers,
          polylines: polylines,
          fitPoints: _fitPoints(),
          followPoint: widget.followProvider ? provider : null,
          offlineMapPath: offlineMapPath,
          fitPadding: EdgeInsets.all(40.r),
        ),
        if (_loadingRoute)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );

    if (widget.expandToFill) {
      return mapStack;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: widget.height ?? 260.h,
        child: mapStack,
      ),
    );
  }
}
