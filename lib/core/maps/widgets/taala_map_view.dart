import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taal/core/helpers/connectivity_helper.dart';
import 'package:taal/core/maps/google/google_maps_config.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/safe_map_controller.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/live_map_marker.dart';
import 'package:taal/core/maps/widgets/nav_vehicle_bitmap.dart';
import 'package:taal/core/maps/widgets/nav_vehicle_marker.dart';
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
    this.offlineMapPaths = const [],
    this.onMapReady,
    this.onTap,
    this.onLongPress,
    this.onMoved,
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
  final List<String> offlineMapPaths;
  final VoidCallback? onMapReady;
  final TapCallback? onTap;
  final LongPressCallback? onLongPress;
  final ValueChanged<LatLng>? onMoved;
  final EdgeInsets? fitPadding;
  final int cameraRevision;

  @override
  State<TaalaMapView> createState() => _TaalaMapViewState();
}

class _TaalaMapViewState extends State<TaalaMapView> {
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);
  gmaps.GoogleMapController? _googleController;
  bool _googleReadyNotified = false;
  gmaps.CameraPosition? _lastGoogleCamera;
  bool _applyingGoogleCamera = false;
  gmaps.BitmapDescriptor? _vehicleIcon;
  final Map<String, gmaps.BitmapDescriptor> _labeledIcons = {};
  StreamSubscription<bool>? _connectivitySub;
  bool _online = true;

  bool get _hasOfflineTiles =>
      (widget.offlineMapPath != null && widget.offlineMapPath!.isNotEmpty) ||
      widget.offlineMapPaths.isNotEmpty;

  bool get _useGoogle =>
      GoogleMapsConfig.useGoogleMapWidget && (_online || !_hasOfflineTiles);

  double get _tilt =>
      widget.navigationFollow ? 58 : MapStyleConfig.browseTilt;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVehicleIcon());
    unawaited(_loadLabeledIcons());
    unawaited(_watchConnectivity());
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyCamera());
  }

  Future<void> _watchConnectivity() async {
    _online = await ConnectivityHelper.connected;
    if (mounted) setState(() {});
    _connectivitySub = ConnectivityHelper.onlineChanges.listen((online) {
      if (!mounted || online == _online) return;
      setState(() => _online = online);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _loadVehicleIcon() async {
    final icon = await createNavVehicleBitmap();
    if (!mounted) return;
    setState(() => _vehicleIcon = icon);
  }

  Future<void> _loadLabeledIcons() async {
    var changed = false;
    for (final marker in widget.markers) {
      final label = marker.label?.trim() ?? '';
      if (label.isEmpty || _labeledIcons.containsKey(label)) continue;
      _labeledIcons[label] = await createLabeledPinBitmap(
        label: label,
        color: marker.color,
      );
      changed = true;
    }
    if (changed && mounted) setState(() {});
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
      unawaited(_loadLabeledIcons());
    }
  }

  void _onFlutterReady() {
    _safeMap.markReady();
    widget.onMapReady?.call();
    _applyCamera();
  }

  gmaps.LatLng _toGoogle(LatLng point) =>
      gmaps.LatLng(point.latitude, point.longitude);

  void _applyCamera() {
    if (_useGoogle) {
      unawaited(_applyGoogleCamera());
      return;
    }

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

  Future<void> _applyGoogleCamera() async {
    final controller = _googleController;
    if (controller == null) return;
    _applyingGoogleCamera = true;
    try {
      final follow = widget.followPoint;
      if (follow != null) {
        final zoom = widget.navigationFollow
            ? widget.initialZoom.clamp(15.0, 17.8)
            : widget.initialZoom.clamp(13.0, 17.5);
        await controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: _toGoogle(follow),
              zoom: zoom,
              tilt: _tilt,
              bearing: widget.followBearing ?? 0,
            ),
          ),
        );
        return;
      }

      final points = widget.fitPoints;
      if (points == null || points.isEmpty) return;
      if (points.length == 1) {
        await controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: _toGoogle(points.first),
              zoom: widget.initialZoom,
              tilt: _tilt,
            ),
          ),
        );
        return;
      }

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
      await controller.animateCamera(
        gmaps.CameraUpdate.newLatLngBounds(
          gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLat, minLng),
            northeast: gmaps.LatLng(maxLat, maxLng),
          ),
          56,
        ),
      );
      final zoom = await controller.getZoomLevel();
      final region = await controller.getVisibleRegion();
      await controller.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(
              (region.northeast.latitude + region.southwest.latitude) / 2,
              (region.northeast.longitude + region.southwest.longitude) / 2,
            ),
            zoom: zoom < 15.5 ? 15.5 : zoom,
            tilt: _tilt,
            bearing: widget.followBearing ?? 0,
          ),
        ),
      );
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _applyingGoogleCamera = false;
      });
    }
  }

  Set<gmaps.Marker> _googleMarkers() {
    return {
      for (var i = 0; i < widget.markers.length; i++)
        gmaps.Marker(
          markerId: gmaps.MarkerId('m$i'),
          position: _toGoogle(widget.markers[i].point),
          rotation: widget.markers[i].headingDegrees ?? 0,
          flat: widget.markers[i].headingDegrees != null,
          anchor: widget.markers[i].headingDegrees != null
              ? const Offset(0.5, 0.5)
              : const Offset(0.5, 1),
          icon: widget.markers[i].headingDegrees != null && _vehicleIcon != null
              ? _vehicleIcon!
              : ((widget.markers[i].label ?? '').isNotEmpty &&
                      _labeledIcons[widget.markers[i].label] != null
                  ? _labeledIcons[widget.markers[i].label]!
                  : gmaps.BitmapDescriptor.defaultMarkerWithHue(
                      HSLColor.fromColor(widget.markers[i].color).hue,
                    )),
          consumeTapEvents: widget.markers[i].onTap != null,
          onTap: widget.markers[i].onTap,
        ),
    };
  }

  Set<gmaps.Polyline> _googlePolylines() {
    final lines = <gmaps.Polyline>{};
    for (var i = 0; i < widget.polylines.length; i++) {
      final line = widget.polylines[i];
      if (line.points.length < 2) continue;
      final points = line.points.map(_toGoogle).toList();
      if (!line.dashed) {
        lines.add(
          gmaps.Polyline(
            polylineId: gmaps.PolylineId('casing$i'),
            points: points,
            color: MapStyleConfig.routeCasingColor,
            width: MapStyleConfig.routeCasingWidth.round(),
          ),
        );
      }
      lines.add(
        gmaps.Polyline(
          polylineId: gmaps.PolylineId('line$i'),
          points: points,
          color: line.dashed ? line.color : MapStyleConfig.routeColor,
          width: line.dashed
              ? line.width.round()
              : MapStyleConfig.routeWidth.round(),
        ),
      );
    }
    return lines;
  }

  Widget _buildGoogleMap() {
    final start = widget.followPoint ?? widget.initialCenter;
    return gmaps.GoogleMap(
      key: ValueKey(
        'gmap-${Localizations.localeOf(context).languageCode}',
      ),
      initialCameraPosition: gmaps.CameraPosition(
        target: _toGoogle(start),
        zoom: widget.initialZoom,
        tilt: _tilt,
        bearing: widget.followBearing ?? 0,
      ),
      style: MapStyleConfig.googleNavigationMapStyle,
      buildingsEnabled: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: widget.allowRotate || widget.navigationFollow,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      trafficEnabled: false,
      markers: _googleMarkers(),
      polylines: _googlePolylines(),
      onTap: (point) => widget.onTap?.call(
        TapPosition(Offset.zero, Offset.zero),
        LatLng(point.latitude, point.longitude),
      ),
      onLongPress: (point) => widget.onLongPress?.call(
        TapPosition(Offset.zero, Offset.zero),
        LatLng(point.latitude, point.longitude),
      ),
      onCameraMove: (position) => _lastGoogleCamera = position,
      onCameraIdle: () {
        if (_applyingGoogleCamera) return;
        final position = _lastGoogleCamera;
        if (position == null) return;
        widget.onMoved?.call(
          LatLng(position.target.latitude, position.target.longitude),
        );
      },
      onMapCreated: (controller) async {
        _googleController = controller;
        if (!_googleReadyNotified) {
          _googleReadyNotified = true;
          widget.onMapReady?.call();
        }
        await _applyGoogleCamera();
      },
    );
  }

  Widget _buildFlutterMap() {
    final flags = widget.allowRotate
        ? InteractiveFlag.all
        : InteractiveFlag.all & ~InteractiveFlag.rotate;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: widget.initialZoom,
        onMapReady: _onFlutterReady,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture) widget.onMoved?.call(camera.center);
        },
        interactionOptions: InteractionOptions(flags: flags),
      ),
      children: [
        ...HybridMapTileLayer.layers(
          offlineMapPath: widget.offlineMapPath,
          offlineMapPaths: widget.offlineMapPaths,
          languageCode: Localizations.localeOf(context).languageCode,
        ),
        ...widget.polylines.expand((line) {
          if (line.points.length < 2) {
            return const <Widget>[];
          }
          final pattern = line.dashed
              ? StrokePattern.dashed(segments: [8, 10])
              : StrokePattern.solid();
          final layers = <Widget>[];
          if (!line.dashed) {
            layers.add(
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: line.points,
                    color: MapStyleConfig.routeCasingColor,
                    strokeWidth: MapStyleConfig.routeCasingWidth,
                    pattern: pattern,
                  ),
                ],
              ),
            );
          }
          layers.add(
            PolylineLayer(
              polylines: [
                Polyline(
                  points: line.points,
                  color: line.dashed ? line.color : MapStyleConfig.routeColor,
                  strokeWidth: line.dashed
                      ? line.width
                      : MapStyleConfig.routeWidth,
                  pattern: pattern,
                ),
              ],
            ),
          );
          return layers;
        }),
        MarkerLayer(
          markers: widget.markers
              .map(
                (marker) {
                  final hasLabel = (marker.label ?? '').isNotEmpty;
                  final iconChild = marker.headingDegrees != null
                      ? NavVehicleMarker(
                          headingDegrees: marker.headingDegrees!,
                        )
                      : marker.livePulse && marker.icon != null
                          ? LiveMapMarker(
                              icon: marker.icon!,
                              color: marker.color,
                              size: marker.iconSize,
                            )
                          : Icon(
                              marker.icon ?? Icons.location_on,
                              color: marker.color,
                              size: marker.iconSize,
                            );
                  return Marker(
                  point: marker.point,
                  width: hasLabel
                      ? 88
                      : marker.headingDegrees != null
                          ? 26
                          : marker.livePulse
                              ? 52
                              : 44,
                  height: hasLabel
                      ? 72
                      : marker.headingDegrees != null
                          ? 26
                          : marker.livePulse
                              ? 52
                              : 44,
                  child: GestureDetector(
                    onTap: marker.onTap,
                    child: hasLabel
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              iconChild,
                              Text(
                                marker.label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: marker.color,
                                ),
                              ),
                            ],
                          )
                        : iconChild,
                  ),
                );
                },
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _useGoogle ? _buildGoogleMap() : _buildFlutterMap();
  }
}
