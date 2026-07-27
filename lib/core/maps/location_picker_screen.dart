import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final PickedLocation? initial;

  static Future<PickedLocation?> open(
    BuildContext context, {
    PickedLocation? initial,
  }) {
    return Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initial: initial),
      ),
    );
  }

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _mapController = MapController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();

  late LatLng _center;
  String? _address;
  bool _loadingGps = false;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initial != null
        ? LatLng(widget.initial!.latitude, widget.initial!.longitude)
        : MapsHelper.defaultCenter;
    _address = widget.initial?.address;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_center, 15);
      if (widget.initial == null) {
        _resolveAddress();
      }
    });
  }

  Future<void> _resolveAddress() async {
    setState(() => _loadingAddress = true);
    final address = await _geocoding.resolveAddress(
      _center.latitude,
      _center.longitude,
    );
    if (!mounted) return;
    setState(() {
      _address = address;
      _loadingAddress = false;
    });
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _loadingGps = true);
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);

    if (current == null) {
      AppMessages.showError(context, AppStrings.locationPermissionDenied.tr());
      return;
    }

    _center = LatLng(current.latitude, current.longitude);
    _mapController.move(_center, 16);
    await _resolveAddress();
  }

  void _confirm() {
    Navigator.of(context).pop(
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.pickLocationOnMap.tr()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  setState(() => _center = _mapController.camera.center);
                  _resolveAddress();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapStyleConfig.tileUrlTemplate,
                subdomains: MapStyleConfig.tileSubdomains,
                userAgentPackageName: MapStyleConfig.userAgentPackageName,
              ),
            ],
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36.h),
                child: Icon(
                  Icons.location_on,
                  size: 48.r,
                  color: AppColors.primaryColor,
                  shadows: const [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: REdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                AppStrings.mapLocationHint.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.commentColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16.w,
            bottom: 190.h,
            child: FloatingActionButton.extended(
              heroTag: 'gps',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              onPressed: _loadingGps ? null : _goToCurrentLocation,
              icon: _loadingGps
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(AppStrings.useMyLocation.tr()),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: REdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadingAddress)
                    const Center(child: CircularProgressIndicator())
                  else if (_address != null && _address!.isNotEmpty) ...[
                    Text(
                      _address!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    8.height,
                  ],
                  Text(
                    '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  16.height,
                  CustomButton.filled(
                    text: AppStrings.confirmLocation.tr(),
                    onTap: _confirm,
                    height: 48.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
