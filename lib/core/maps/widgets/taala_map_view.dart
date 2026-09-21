import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
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
    this.followBearing,
    this.navigationFollow = false,
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
  final double? followBearing;
  final bool navigationFollow;
  final bool allowRotate;
  final String? offlineMapPath;
  final VoidCallback? onMapReady;
  final EdgeInsets? fitPadding;
  final int cameraRevision;

  @override
  State<TaalaMapView> createState() => _TaalaMapViewState();
}

class _TaalaMapViewState extends State<TaalaMapView> {
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyCamera());
  }

  @override
  void didUpdateWidget(covariant TaalaMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fitPoints != widget.fitPoints ||
        oldWidget.followPoint != widget.followPoint ||
        oldWidget.followBearing != widget.followBearing ||
        oldWidget.navigationFollow != widget.navigationFollow ||
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
    if (widget.navigationFollow && follow != null) {
      final zoom = _mapController.camera.zoom.clamp(15.0, 17.5);
      _safeMap.move(follow, zoom, bearing: widget.followBearing);
      return;
    }

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
