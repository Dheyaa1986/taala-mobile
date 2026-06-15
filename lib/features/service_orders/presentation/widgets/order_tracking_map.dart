import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';

class OrderTrackingMap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final clientPoint = LatLng(clientLatitude, clientLongitude);
    final providerPoint = providerLatitude != null && providerLongitude != null
        ? LatLng(providerLatitude!, providerLongitude!)
        : null;

    final points = <LatLng>[clientPoint];
    if (providerPoint != null) points.add(providerPoint);

    final bounds = LatLngBounds.fromPoints(points);
    final center = providerPoint != null
        ? LatLng(
            (clientLatitude + providerLatitude!) / 2,
            (clientLongitude + providerLongitude!) / 2,
          )
        : clientPoint;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 220.h,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: EdgeInsets.all(48.r),
            ),
            initialCenter: center,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mintops.taala',
            ),
            if (providerPoint != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [clientPoint, providerPoint],
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: clientPoint,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.home,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                if (providerPoint != null)
                  Marker(
                    point: providerPoint,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.local_shipping,
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
