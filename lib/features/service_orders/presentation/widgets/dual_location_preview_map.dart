import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/picked_location.dart';

class DualLocationPreviewMap extends StatefulWidget {
  const DualLocationPreviewMap({
    super.key,
    required this.origin,
    this.destination,
    this.height,
  });

  final PickedLocation origin;
  final PickedLocation? destination;
  final double? height;

  @override
  State<DualLocationPreviewMap> createState() => _DualLocationPreviewMapState();
}

class _DualLocationPreviewMapState extends State<DualLocationPreviewMap> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitCamera());
  }

  @override
  void didUpdateWidget(covariant DualLocationPreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitCamera());
    }
  }

  void _fitCamera() {
    final points = <LatLng>[
      LatLng(widget.origin.latitude, widget.origin.longitude),
    ];
    final destination = widget.destination;
    if (destination != null) {
      points.add(LatLng(destination.latitude, destination.longitude));
    }

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(48.r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final originPoint =
        LatLng(widget.origin.latitude, widget.origin.longitude);
    final destination = widget.destination;
    final destinationPoint = destination == null
        ? null
        : LatLng(destination.latitude, destination.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: widget.height ?? 220.h,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: originPoint,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: MapStyleConfig.tileUrlTemplate,
              subdomains: MapStyleConfig.tileSubdomains,
              userAgentPackageName: MapStyleConfig.userAgentPackageName,
              maxZoom: 19,
            ),
            if (destinationPoint != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [originPoint, destinationPoint],
                    color: AppColors.primaryColor.withValues(alpha: 0.7),
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: originPoint,
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
        ),
      ),
    );
  }
}
