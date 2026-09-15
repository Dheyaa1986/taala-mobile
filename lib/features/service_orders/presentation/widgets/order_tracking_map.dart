import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';

class OrderTrackingMap extends StatefulWidget {
  const OrderTrackingMap({
    super.key,
    required this.clientLatitude,
    required this.clientLongitude,
    this.providerLatitude,
    this.providerLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
  });

  final double clientLatitude;
  final double clientLongitude;
  final double? providerLatitude;
  final double? providerLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  final _mapController = MapController();
  final _routing = getIt<OsrmRoutingService>();
  List<LatLng> _providerRoutePoints = [];
  List<LatLng> _destinationRoutePoints = [];
  bool _loadingRoute = false;
  LatLng? _lastRouteFrom;

  @override
  void initState() {
    super.initState();
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
      _fitCamera();
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 260.h,
        child: Stack(
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
                TileLayer(
                  urlTemplate: MapStyleConfig.tileUrlTemplate,
                  subdomains: MapStyleConfig.tileSubdomains,
                  userAgentPackageName: MapStyleConfig.userAgentPackageName,
                  maxZoom: 19,
                ),
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
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.primaryColor,
                          size: 34,
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
        ),
      ),
    );
  }
}
