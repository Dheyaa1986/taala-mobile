import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/safe_map_controller.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
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
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);
  final _routing = getIt<OsrmRoutingService>();

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
      _fitCamera();
      unawaited(_loadRoute());
    }
  }

  void _onMapReady() {
    _safeMap.markReady();
    _fitCamera();
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
    _fitCamera();
  }

  void _fitCamera() {
    final points = <LatLng>[_originPoint];
    final destination = _destinationPoint;
    if (destination != null) points.add(destination);
    if (_routePoints.isNotEmpty) points.addAll(_routePoints);

    if (points.length == 1) {
      _safeMap.move(points.first, 15);
      return;
    }

    _safeMap.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(48.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinationPoint = _destinationPoint;
    final routePolyline = _routePoints.length >= 2
        ? _routePoints
        : destinationPoint != null
            ? [_originPoint, destinationPoint]
            : <LatLng>[];

    final map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _originPoint,
        initialZoom: 14,
        onMapReady: _onMapReady,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        HybridMapTileLayer(offlineMapPath: offlineMapPath),
        if (routePolyline.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePolyline,
                color: AppColors.primaryColor.withValues(alpha: 0.85),
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _originPoint,
              width: 36,
              height: 36,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 36,
              ),
            ),
            if (destinationPoint != null)
              Marker(
                point: destinationPoint,
                width: 36,
                height: 36,
                child: Icon(
                  Icons.flag,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
          ],
        ),
      ],
    );

    if (widget.expandToFill) {
      return Stack(
        children: [
          Positioned.fill(child: map),
          if (_loadingRoute)
            Positioned(
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
            ),
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
            if (_loadingRoute)
              Positioned(
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
              ),
          ],
        ),
      ),
    );
  }
}
