import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/widgets/nav_vehicle_bitmap.dart';

/// Google Maps view for provider in-app navigation.
class GoogleNavigationMap extends StatefulWidget {
  const GoogleNavigationMap({
    super.key,
    required this.target,
    this.provider,
    this.routePoints = const [],
    this.followNavigation = false,
    this.fitFullRoute = false,
    this.bearing,
    this.cameraRevision = 0,
    this.onMapReady,
  });

  final LatLng target;
  final LatLng? provider;
  final List<LatLng> routePoints;
  final bool followNavigation;
  final bool fitFullRoute;
  final double? bearing;
  final int cameraRevision;
  final VoidCallback? onMapReady;

  @override
  State<GoogleNavigationMap> createState() => _GoogleNavigationMapState();
}

class _GoogleNavigationMapState extends State<GoogleNavigationMap> {
  gmaps.GoogleMapController? _controller;
  bool _readyNotified = false;
  gmaps.BitmapDescriptor? _vehicleIcon;
  bool _applyingCamera = false;
  double? _userZoom;
  bool _userHold = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVehicleIcon());
  }

  Future<void> _loadVehicleIcon() async {
    final icon = await createNavVehicleBitmap();
    if (!mounted) return;
    setState(() => _vehicleIcon = icon);
  }

  @override
  void didUpdateWidget(covariant GoogleNavigationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cameraRevision != oldWidget.cameraRevision) {
      _userHold = false;
      unawaited(_updateCamera());
      return;
    }
    if (widget.followNavigation != oldWidget.followNavigation ||
        widget.fitFullRoute != oldWidget.fitFullRoute ||
        widget.provider != oldWidget.provider ||
        widget.bearing != oldWidget.bearing) {
      unawaited(_updateCamera());
    }
  }

  gmaps.LatLng _toGoogle(LatLng point) =>
      gmaps.LatLng(point.latitude, point.longitude);

  Set<gmaps.Marker> _buildMarkers() {
    final markers = <gmaps.Marker>{
      gmaps.Marker(
        markerId: const gmaps.MarkerId('target'),
        position: _toGoogle(widget.target),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
      ),
    };

    final provider = widget.provider;
    if (provider != null) {
      markers.add(
        gmaps.Marker(
          markerId: const gmaps.MarkerId('provider'),
          position: _toGoogle(provider),
          rotation: widget.bearing ?? 0,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: _vehicleIcon ??
              gmaps.BitmapDescriptor.defaultMarkerWithHue(
                gmaps.BitmapDescriptor.hueAzure,
              ),
        ),
      );
    }

    return markers;
  }

  Set<gmaps.Polyline> _buildPolylines() {
    if (widget.routePoints.length < 2) return const {};
    final points = widget.routePoints.map(_toGoogle).toList();
    return {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route_casing'),
        points: points,
        color: MapStyleConfig.routeCasingColor,
        width: MapStyleConfig.routeCasingWidth.round(),
      ),
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: points,
        color: MapStyleConfig.routeColor,
        width: MapStyleConfig.routeWidth.round(),
      ),
    };
  }

  Future<void> _updateCamera() async {
    final controller = _controller;
    if (controller == null) return;
    _applyingCamera = true;
    try {
      final provider = widget.provider;
      if (widget.fitFullRoute ||
          (!widget.followNavigation && widget.routePoints.length >= 2)) {
        final bounds = _boundsFor([
          if (provider != null) provider,
          widget.target,
          ...widget.routePoints,
        ]);
        await controller.animateCamera(
          gmaps.CameraUpdate.newLatLngBounds(bounds, 72),
        );
        return;
      }

      if (widget.followNavigation && provider != null) {
        var zoom = _userZoom ?? 16.4;
        try {
          zoom = _userHold ? (_userZoom ?? await controller.getZoomLevel()) : 16.4;
        } catch (_) {}
        await controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: _toGoogle(provider),
              zoom: zoom.clamp(4.0, 20.0),
              bearing: widget.bearing ?? 0,
              tilt: _userHold ? 0 : 58,
            ),
          ),
        );
        return;
      }

      if (provider == null) {
        await controller.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(_toGoogle(widget.target), 14),
        );
      }
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        _applyingCamera = false;
      });
    }
  }

  gmaps.LatLngBounds _boundsFor(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLng),
      northeast: gmaps.LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.provider ?? widget.target;

    return gmaps.GoogleMap(
      key: ValueKey(
        'gnav-${Localizations.localeOf(context).languageCode}',
      ),
      initialCameraPosition: gmaps.CameraPosition(
        target: _toGoogle(initial),
        zoom: 16,
        tilt: 58,
      ),
      style: MapStyleConfig.googleNavigationMapStyle,
      buildingsEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: true,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: false,
      mapToolbarEnabled: false,
      trafficEnabled: true,
      padding: const EdgeInsets.only(top: 118, bottom: 118),
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
      onCameraMove: (position) {
        if (_applyingCamera) return;
        _userHold = true;
        _userZoom = position.zoom;
      },
      onMapCreated: (controller) async {
        _controller = controller;
        if (!_readyNotified) {
          _readyNotified = true;
          widget.onMapReady?.call();
        }
        await _updateCamera();
      },
    );
  }
}
