import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/maps/osrm_routing_service.dart';

class OrderTrackingMap extends StatefulWidget {
  const OrderTrackingMap({
    super.key,
    required this.clientLatitude,
    required this.clientLongitude,
    this.providerLatitude,
    this.providerLongitude,
  });

  final double clientLatitude;
  final double clientLongitude;
  final double? providerLatitude;
  final double? providerLongitude;

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  final _mapController = MapController();
  final _routing = getIt<OsrmRoutingService>();
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;
  LatLng? _lastRouteFrom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
      _fitCamera();
    });
  }

  @override
  void didUpdateWidget(covariant OrderTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final providerChanged =
        oldWidget.providerLatitude != widget.providerLatitude ||
            oldWidget.providerLongitude != widget.providerLongitude;
    if (providerChanged) {
      _loadRoute();
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

  bool _shouldRefetchRoute(LatLng from) {
    if (_lastRouteFrom == null) return true;
    const distance = Distance();
    return distance(_lastRouteFrom!, from) > 80;
  }

  Future<void> _loadRoute() async {
    final provider = _providerPoint;
    if (provider == null) {
      if (mounted) {
        setState(() {
          _routePoints = [];
          _loadingRoute = false;
        });
      }
      return;
    }

    if (!_shouldRefetchRoute(provider)) return;

    setState(() => _loadingRoute = true);
    final points = await _routing.fetchDrivingRoute(provider, _clientPoint);
    if (!mounted) return;
    setState(() {
      _routePoints = points;
      _loadingRoute = false;
      _lastRouteFrom = provider;
    });
  }

  void _fitCamera() {
    final provider = _providerPoint;
    final points = <LatLng>[_clientPoint];
    if (provider != null) points.add(provider);
    if (_routePoints.isNotEmpty) points.addAll(_routePoints);

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
    final routePolyline = _routePoints.isNotEmpty
        ? _routePoints
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
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mintops.taala',
                  maxZoom: 19,
                ),
                if (routePolyline.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePolyline,
                        color: AppColors.primaryColor,
                        strokeWidth: 5,
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
                        Icons.home_rounded,
                        color: Colors.blue,
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
