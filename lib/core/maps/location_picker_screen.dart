import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/design_system/tokens/taala_shadows.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/maps/safe_map_controller.dart';

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
  late final SafeMapController _safeMap = SafeMapController(_mapController);
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
  }

  void _onMapReady() {
    _safeMap.markReady();
    _safeMap.move(_center, 15);
    if (widget.initial == null) {
      unawaited(_resolveAddress());
    }
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
    _safeMap.move(_center, 16);
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
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

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
              onMapReady: _onMapReady,
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
                  color: tokens.primary,
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
                color: tokens.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: TaalaShadows.soft(brightness),
              ),
              child: Text(
                AppStrings.mapLocationHint.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
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
              backgroundColor: tokens.surface,
              foregroundColor: tokens.primary,
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
              padding: REdgeInsets.fromLTRB(
                16,
                16,
                16,
                24 + context.safeBottomInset,
              ),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: TaalaShadows.soft(brightness),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                    ),
                    8.height,
                  ],
                  Text(
                    '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                  ),
                  16.height,
                  TaalaButton(
                    label: AppStrings.confirmLocation.tr(),
                    onPressed: _confirm,
                    height: 48,
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
