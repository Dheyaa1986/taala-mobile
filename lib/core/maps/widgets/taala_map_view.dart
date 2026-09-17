import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:taal/core/maps/mapbox/mapbox_config.dart';
import 'package:taal/core/maps/safe_map_controller.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/live_map_marker.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';

class TaalaMapView extends StatefulWidget {
  const TaalaMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 14,
    this.markers = const [],
    this.polylines = const [],
    this.fitPoints,
    this.followPoint,
    this.allowRotate = false,
    this.offlineMapPath,
    this.onMapReady,
    this.fitPadding,
    this.cameraRevision = 0,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final List<TaalaMapMarker> markers;
  final List<TaalaMapPolyline> polylines;
  final List<LatLng>? fitPoints;
  final LatLng? followPoint;
  final bool allowRotate;
  final String? offlineMapPath;
  final VoidCallback? onMapReady;
  final EdgeInsets? fitPadding;
  final int cameraRevision;

  @override
  State<TaalaMapView> createState() => _TaalaMapViewState();
}

class _TaalaMapViewState extends State<TaalaMapView> {
  @override
  Widget build(BuildContext context) {
    if (MapboxConfig.isEnabled) {
      return _TaalaMapboxView(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        markers: widget.markers,
        polylines: widget.polylines,
        fitPoints: widget.fitPoints,
        followPoint: widget.followPoint,
        onMapReady: widget.onMapReady,
        fitPadding: widget.fitPadding,
        cameraRevision: widget.cameraRevision,
      );
    }

    return _TaalaFlutterMapView(
      initialCenter: widget.initialCenter,
      initialZoom: widget.initialZoom,
      markers: widget.markers,
      polylines: widget.polylines,
      fitPoints: widget.fitPoints,
      followPoint: widget.followPoint,
      allowRotate: widget.allowRotate,
      offlineMapPath: widget.offlineMapPath,
      onMapReady: widget.onMapReady,
      fitPadding: widget.fitPadding,
      cameraRevision: widget.cameraRevision,
    );
  }
}

class _TaalaFlutterMapView extends StatefulWidget {
  const _TaalaFlutterMapView({
    required this.initialCenter,
    required this.initialZoom,
    required this.markers,
    required this.polylines,
    this.fitPoints,
    this.followPoint,
    required this.allowRotate,
    this.offlineMapPath,
    this.onMapReady,
    this.fitPadding,
    this.cameraRevision = 0,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final List<TaalaMapMarker> markers;
  final List<TaalaMapPolyline> polylines;
  final List<LatLng>? fitPoints;
  final LatLng? followPoint;
  final bool allowRotate;
  final String? offlineMapPath;
  final VoidCallback? onMapReady;
  final EdgeInsets? fitPadding;
  final int cameraRevision;

  @override
  State<_TaalaFlutterMapView> createState() => _TaalaFlutterMapViewState();
}

class _TaalaFlutterMapViewState extends State<_TaalaFlutterMapView> {
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyCamera());
  }

  @override
  void didUpdateWidget(covariant _TaalaFlutterMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fitPoints != widget.fitPoints ||
        oldWidget.followPoint != widget.followPoint ||
        oldWidget.markers != widget.markers ||
        oldWidget.polylines != widget.polylines ||
        oldWidget.cameraRevision != widget.cameraRevision) {
      _applyCamera();
    }
  }

  void _onMapReady() {
    _safeMap.markReady();
    widget.onMapReady?.call();
    _applyCamera();
  }

  void _applyCamera() {
    final follow = widget.followPoint;
    if (follow != null) {
      final zoom = _mapController.camera.zoom.clamp(13.0, 17.0);
      _safeMap.move(follow, zoom);
      return;
    }

    final points = widget.fitPoints;
    if (points == null || points.isEmpty) return;
    if (points.length == 1) {
      _safeMap.move(points.first, widget.initialZoom);
      return;
    }

    _safeMap.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: widget.fitPadding ?? EdgeInsets.all(40.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flags = widget.allowRotate
        ? InteractiveFlag.all
        : InteractiveFlag.all & ~InteractiveFlag.rotate;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        onMapReady: _onMapReady,
        interactionOptions: InteractionOptions(flags: flags),
      ),
      children: [
        HybridMapTileLayer(offlineMapPath: widget.offlineMapPath),
        ...widget.polylines.map(
          (line) {
            if (line.points.length < 2) return const SizedBox.shrink();
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: line.points,
                  color: line.color,
                  strokeWidth: line.width,
                  pattern: line.dashed
                      ? StrokePattern.dashed(segments: [8, 10])
                      : StrokePattern.solid(),
                ),
              ],
            );
          },
        ),
        MarkerLayer(
          markers: widget.markers
              .map(
                (marker) => Marker(
                  point: marker.point,
                  width: marker.livePulse ? 52 : 44,
                  height: marker.livePulse ? 52 : 44,
                  child: marker.livePulse && marker.icon != null
                      ? LiveMapMarker(
                          icon: marker.icon!,
                          color: marker.color,
                          size: marker.iconSize,
                        )
                      : Icon(
                          marker.icon ?? Icons.location_on,
                          color: marker.color,
                          size: marker.iconSize,
                        ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TaalaMapboxView extends StatefulWidget {
  const _TaalaMapboxView({
    required this.initialCenter,
    required this.initialZoom,
    required this.markers,
    required this.polylines,
    this.fitPoints,
    this.followPoint,
    this.onMapReady,
    this.fitPadding,
    this.cameraRevision = 0,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final List<TaalaMapMarker> markers;
  final List<TaalaMapPolyline> polylines;
  final List<LatLng>? fitPoints;
  final LatLng? followPoint;
  final VoidCallback? onMapReady;
  final EdgeInsets? fitPadding;
  final int cameraRevision;

  @override
  State<_TaalaMapboxView> createState() => _TaalaMapboxViewState();
}

class _TaalaMapboxViewState extends State<_TaalaMapboxView> {
  mapbox.MapboxMap? _mapboxMap;
  mapbox.PolylineAnnotationManager? _polylineManager;
  mapbox.CircleAnnotationManager? _circleManager;
  bool _styleReady = false;

  @override
  void didUpdateWidget(covariant _TaalaMapboxView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers != widget.markers ||
        oldWidget.polylines != widget.polylines ||
        oldWidget.fitPoints != widget.fitPoints ||
        oldWidget.followPoint != widget.followPoint ||
        oldWidget.cameraRevision != widget.cameraRevision) {
      unawaited(_syncAnnotations());
      unawaited(_applyCamera());
    }
  }

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _mapboxMap = map;
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    _styleReady = true;
    final map = _mapboxMap;
    if (map == null) return;

    _polylineManager ??=
        await map.annotations.createPolylineAnnotationManager();
    _circleManager ??= await map.annotations.createCircleAnnotationManager();

    widget.onMapReady?.call();
    await _syncAnnotations();
    await _applyCamera();
  }

  Future<void> _syncAnnotations() async {
    if (!_styleReady ||
        _polylineManager == null ||
        _circleManager == null) {
      return;
    }

    await _polylineManager!.deleteAll();
    await _circleManager!.deleteAll();

    final polylineOptions = <mapbox.PolylineAnnotationOptions>[];
    for (final line in widget.polylines) {
      if (line.points.length < 2) continue;
      polylineOptions.add(
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString(
            coordinates: line.points
                .map((p) => mapbox.Position(p.longitude, p.latitude))
                .toList(growable: false),
          ),
          lineColor: line.color.toARGB32(),
          lineWidth: line.width,
          lineOpacity: 0.9,
        ),
      );
    }
    if (polylineOptions.isNotEmpty) {
      await _polylineManager!.createMulti(polylineOptions);
    }

    final circleOptions = <mapbox.CircleAnnotationOptions>[];
    for (final marker in widget.markers) {
      circleOptions.add(
        mapbox.CircleAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              marker.point.longitude,
              marker.point.latitude,
            ),
          ),
          circleColor: marker.color.toARGB32(),
          circleRadius: marker.livePulse ? 10 : 8,
          circleStrokeWidth: 2,
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    }
    if (circleOptions.isNotEmpty) {
      await _circleManager!.createMulti(circleOptions);
    }
  }

  Future<void> _applyCamera() async {
    final map = _mapboxMap;
    if (map == null || !_styleReady) return;

    final follow = widget.followPoint;
    if (follow != null) {
      final state = await map.getCameraState();
      await map.setCamera(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(follow.longitude, follow.latitude),
          ),
          zoom: state.zoom.clamp(13, 17),
        ),
      );
      return;
    }

    final points = widget.fitPoints;
    if (points == null || points.length < 2) {
      if (points != null && points.length == 1) {
        await map.setCamera(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                points.first.longitude,
                points.first.latitude,
              ),
            ),
            zoom: widget.initialZoom,
          ),
        );
      }
      return;
    }

    final bounds = _coordinateBounds(points);
    final padding = widget.fitPadding ?? EdgeInsets.all(40.r);
    final camera = await map.cameraForCoordinateBounds(
      bounds,
      mapbox.MbxEdgeInsets(
        top: padding.top,
        left: padding.left,
        bottom: padding.bottom,
        right: padding.right,
      ),
      null,
      null,
      null,
      null,
    );
    await map.setCamera(camera);
  }

  mapbox.CoordinateBounds _coordinateBounds(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return mapbox.CoordinateBounds(
      southwest: mapbox.Point(
        coordinates: mapbox.Position(minLng, minLat),
      ),
      northeast: mapbox.Point(
        coordinates: mapbox.Position(maxLng, maxLat),
      ),
      infiniteBounds: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return mapbox.MapWidget(
      key: const ValueKey('taala_mapbox'),
      styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
      viewport: mapbox.CameraViewportState(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            widget.initialCenter.longitude,
            widget.initialCenter.latitude,
          ),
        ),
        zoom: widget.initialZoom,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: _onStyleLoaded,
    );
  }
}
