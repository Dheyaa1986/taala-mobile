import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';

/// Google Map for browsing/saving places — same SDK and style as order navigation.
class GoogleBrowseMap extends StatefulWidget {
  const GoogleBrowseMap({
    super.key,
    required this.center,
    this.zoom = 16,
    this.markers = const [],
    this.routePoints = const [],
    this.cameraRevision = 0,
    this.onTap,
    this.onLongPress,
    this.onCameraIdle,
    this.onMarkerTap,
    this.onMapReady,
  });

  final LatLng center;
  final double zoom;
  final List<TaalaMapMarker> markers;
  final List<LatLng> routePoints;
  final int cameraRevision;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<LatLng>? onLongPress;
  final ValueChanged<LatLng>? onCameraIdle;
  final ValueChanged<LatLng>? onMarkerTap;
  final VoidCallback? onMapReady;

  @override
  State<GoogleBrowseMap> createState() => _GoogleBrowseMapState();
}

class _GoogleBrowseMapState extends State<GoogleBrowseMap> {
  gmaps.GoogleMapController? _controller;
  bool _readyNotified = false;

  @override
  void didUpdateWidget(covariant GoogleBrowseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cameraRevision != oldWidget.cameraRevision) {
      unawaited(_moveTo(widget.center, widget.zoom));
    }
  }

  gmaps.LatLng _toGoogle(LatLng point) =>
      gmaps.LatLng(point.latitude, point.longitude);

  Future<void> _moveTo(LatLng point, double zoom) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(target: _toGoogle(point), zoom: zoom),
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers() {
    return {
      for (var i = 0; i < widget.markers.length; i++)
        gmaps.Marker(
          markerId: gmaps.MarkerId('m$i'),
          position: _toGoogle(widget.markers[i].point),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
            _hueFor(widget.markers[i].color),
          ),
          rotation: widget.markers[i].headingDegrees ?? 0,
          flat: widget.markers[i].headingDegrees != null,
          consumeTapEvents: widget.onMarkerTap != null,
          onTap: widget.onMarkerTap == null
              ? null
              : () => widget.onMarkerTap!(widget.markers[i].point),
        ),
    };
  }

  double _hueFor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
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

  @override
  Widget build(BuildContext context) {
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: _toGoogle(widget.center),
        zoom: widget.zoom,
      ),
      style: MapStyleConfig.googleNavigationMapStyle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      trafficEnabled: false,
      padding: const EdgeInsets.only(top: 118, bottom: 132),
      markers: _buildMarkers(),
      polylines: _buildPolylines(),
      onTap: (point) => widget.onTap?.call(
        LatLng(point.latitude, point.longitude),
      ),
      onLongPress: (point) => widget.onLongPress?.call(
        LatLng(point.latitude, point.longitude),
      ),
      onCameraIdle: () async {
        final controller = _controller;
        if (controller == null) return;
        final region = await controller.getVisibleRegion();
        final mid = LatLng(
          (region.northeast.latitude + region.southwest.latitude) / 2,
          (region.northeast.longitude + region.southwest.longitude) / 2,
        );
        widget.onCameraIdle?.call(mid);
      },
      onMapCreated: (controller) async {
        _controller = controller;
        if (!_readyNotified) {
          _readyNotified = true;
          widget.onMapReady?.call();
        }
        await _moveTo(widget.center, widget.zoom);
      },
    );
  }
}
