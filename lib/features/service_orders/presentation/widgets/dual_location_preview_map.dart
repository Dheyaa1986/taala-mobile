import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';
import 'package:taal/core/maps/widgets/taala_map_view.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';

class DualLocationPreviewMap extends StatefulWidget {
  const DualLocationPreviewMap({
    super.key,
    required this.origin,
    this.destination,
    this.height,
    this.expandToFill = false,
  });

  final PickedLocation origin;
  final PickedLocation? destination;
  final double? height;
  final bool expandToFill;

  @override
  State<DualLocationPreviewMap> createState() => _DualLocationPreviewMapState();
}

class _DualLocationPreviewMapState extends State<DualLocationPreviewMap>
    with TaalaOfflineMapMixin {
  final _routing = getIt<TaalaRoutingService>();

  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    unawaited(refreshOfflineMapPath(
      widget.origin.latitude,
      widget.origin.longitude,
    ));
  }

  @override
  void didUpdateWidget(covariant DualLocationPreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      unawaited(_loadRoute());
    }
  }

  void _onMapReady() {
    unawaited(_loadRoute());
  }

  LatLng get _originPoint =>
      LatLng(widget.origin.latitude, widget.origin.longitude);

  LatLng? get _destinationPoint {
    final destination = widget.destination;
    if (destination == null) return null;
    return LatLng(destination.latitude, destination.longitude);
  }

  Future<void> _loadRoute() async {
    final destination = _destinationPoint;
    if (destination == null) {
      if (mounted) setState(() => _routePoints = []);
      return;
    }

    setState(() => _loadingRoute = true);
    final route = await _routing.fetchDrivingRoute(_originPoint, destination);
    if (!mounted) return;
    setState(() {
      _routePoints = route;
      _loadingRoute = false;
    });
  }

  List<LatLng> _fitPoints() {
    final points = <LatLng>[_originPoint];
    final destination = _destinationPoint;
    if (destination != null) points.add(destination);
    if (_routePoints.isNotEmpty) points.addAll(_routePoints);
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final destinationPoint = _destinationPoint;
    final routePolyline = _routePoints.length >= 2
        ? _routePoints
        : destinationPoint != null
            ? [_originPoint, destinationPoint]
            : <LatLng>[];

    final map = TaalaMapView(
      initialCenter: _originPoint,
      initialZoom: 14,
      onMapReady: _onMapReady,
      allowRotate: false,
      offlineMapPath: offlineMapPath,
      fitPoints: _fitPoints(),
      fitPadding: EdgeInsets.all(48.r),
      polylines: routePolyline.length >= 2
          ? [
              TaalaMapPolyline(
                points: routePolyline,
                color: AppColors.primaryColor.withValues(alpha: 0.85),
                width: 5,
              ),
            ]
          : const [],
      markers: [
        TaalaMapMarker(
          point: _originPoint,
          color: Colors.red,
          icon: Icons.location_on,
          iconSize: 36,
        ),
        if (destinationPoint != null)
          TaalaMapMarker(
            point: destinationPoint,
            color: AppColors.primaryColor,
            icon: Icons.flag,
            iconSize: 32,
          ),
      ],
    );

    if (widget.expandToFill) {
      return Stack(
        children: [
          Positioned.fill(child: map),
          if (_loadingRoute) _loadingIndicator(),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: widget.height ?? 220.h,
        child: Stack(
          children: [
            map,
            if (_loadingRoute) _loadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Positioned(
      top: 8.h,
      right: 8.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: REdgeInsets.all(6),
          child: SizedBox(
            width: 18.r,
            height: 18.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
