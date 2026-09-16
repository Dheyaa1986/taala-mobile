import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/live_map_marker.dart';
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
  final _mapController = MapController();
  final _routing = getIt<OsrmRoutingService>();
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
      _loadRoutes();
      _fitCamera();
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
      _loadRoutes();
      if (providerChanged && widget.followProvider && _providerPoint != null) {
        _followProvider(_providerPoint!);
      } else {
        _fitCamera();
      }
    }
  }

  void _followProvider(LatLng provider) {
    final zoom = _mapController.camera.zoom.clamp(13.0, 17.0);
    _mapController.move(provider, zoom);
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

  void _fitCamera() {
    final provider = _providerPoint;
    final destination = _destinationPoint;
    final points = <LatLng>[_clientPoint];
    if (provider != null) points.add(provider);
    if (destination != null) points.add(destination);
    if (_providerRoutePoints.isNotEmpty) points.addAll(_providerRoutePoints);
    if (_destinationRoutePoints.isNotEmpty) {
      points.addAll(_destinationRoutePoints);
    }

    if (points.length == 1) {
      _mapController.move(_clientPoint, 15);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(40.r),
      ),
    );
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

    final mapStack = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _clientPoint,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            HybridMapTileLayer(offlineMapPath: offlineMapPath),
                if (providerPolyline.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: providerPolyline,
                        color: AppColors.primaryColor,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                if (_destinationRoutePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _destinationRoutePoints,
                        color: Colors.green.shade700,
                        strokeWidth: 4,
                        pattern: StrokePattern.dashed(segments: [8, 10]),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _clientPoint,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 34,
                      ),
                    ),
                    if (provider != null)
                      Marker(
                        point: provider,
                        width: 52,
                        height: 52,
                        child: LiveMapMarker(
                          icon: Icons.local_shipping_rounded,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                      ),
                    if (destination != null)
                      Marker(
                        point: destination,
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.flag_rounded,
                          color: Colors.green.shade700,
                          size: 34,
                        ),
                      ),
                  ],
                ),
              ],
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
