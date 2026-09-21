import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

/// Google Maps view for provider in-app navigation.
class GoogleNavigationMap extends StatefulWidget {
  const GoogleNavigationMap({
    super.key,
    required this.target,
    this.provider,
    this.routePoints = const [],
    this.followNavigation = false,
    this.bearing,
    this.cameraRevision = 0,
    this.onMapReady,
  });

  final LatLng target;
  final LatLng? provider;
  final List<LatLng> routePoints;
  final bool followNavigation;
  final double? bearing;
  final int cameraRevision;
  final VoidCallback? onMapReady;

  @override
  State<GoogleNavigationMap> createState() => _GoogleNavigationMapState();
}

class _GoogleNavigationMapState extends State<GoogleNavigationMap> {
  gmaps.GoogleMapController? _controller;
  bool _readyNotified = false;

  @override
  void didUpdateWidget(covariant GoogleNavigationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cameraRevision != oldWidget.cameraRevision ||
        widget.followNavigation != oldWidget.followNavigation) {
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
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  Set<gmaps.Polyline> _buildPolylines() {
    if (widget.routePoints.length < 2) return const {};
    return {
      gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: widget.routePoints.map(_toGoogle).toList(),
        color: const Color(0xFFFFC107),
        width: 6,
      ),
    };
  }

  Future<void> _updateCamera() async {
    final controller = _controller;
    if (controller == null) return;

    final provider = widget.provider;
    if (widget.followNavigation && provider != null) {
      await controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: _toGoogle(provider),
            zoom: 17,
            bearing: widget.bearing ?? 0,
            tilt: 45,
          ),
        ),
      );
      return;
    }

    if (provider == null) {
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(_toGoogle(widget.target), 14),
      );
      return;
    }

    final bounds = _boundsFor([
      provider,
      widget.target,
      ...widget.routePoints,
    ]);
    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(bounds, 64),
    );
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
      initialCameraPosition: gmaps.CameraPosition(
        target: _toGoogle(initial),
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      trafficEnabled: true,
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
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
