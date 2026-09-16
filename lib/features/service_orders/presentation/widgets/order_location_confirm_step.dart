import 'dart:async';

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
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/maps/safe_map_controller.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';

class OrderLocationConfirmStep extends StatefulWidget {
  const OrderLocationConfirmStep({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.onConfirmed,
    this.initial,
    this.autoGpsOnStart = true,
  });

  final String title;
  final String confirmLabel;
  final Future<void> Function(PickedLocation location) onConfirmed;
  final PickedLocation? initial;
  final bool autoGpsOnStart;

  @override
  State<OrderLocationConfirmStep> createState() =>
      _OrderLocationConfirmStepState();
}

class _OrderLocationConfirmStepState extends State<OrderLocationConfirmStep> {
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _placeSearch = getIt<PlaceSearchService>();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  late LatLng _center;
  String? _address;
  List<PlaceSuggestion> _suggestions = [];
  bool _loadingGps = false;
  bool _loadingAddress = false;
  bool _searching = false;
  bool _bootstrapping = false;
  bool _confirming = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _center = widget.initial != null
        ? LatLng(widget.initial!.latitude, widget.initial!.longitude)
        : MapsHelper.defaultCenter;
    _address = widget.initial?.address;
    if (widget.initial != null) {
      _searchController.text = widget.initial!.address ?? '';
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _onMapReady() {
    _safeMap.markReady();
    if (_bootstrapping) return;
    _bootstrapping = true;
    unawaited(_bootstrapAfterMapReady());
  }

  Future<void> _bootstrapAfterMapReady() async {
    if (widget.initial != null) {
      _safeMap.move(_center, 15);
      return;
    }
    if (widget.autoGpsOnStart) {
      await _goToCurrentLocation(silent: true);
    } else if (_address == null) {
      await _resolveAddress();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  PickedLocation get _currentPick => PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      );

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
      if (address != null && address.isNotEmpty) {
        _searchController.text = address;
      }
    });
  }

  Future<void> _goToCurrentLocation({bool silent = false}) async {
    setState(() => _loadingGps = true);
    final current = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;
    setState(() => _loadingGps = false);

    if (current == null) {
      if (!silent) {
        AppMessages.showError(
          context,
          AppStrings.locationPermissionDenied.tr(),
        );
      }
      return;
    }

    _center = LatLng(current.latitude, current.longitude);
    _safeMap.move(_center, 16);
    await _resolveAddress();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = _searchController.text.trim();
      if (query.length < 3) {
        if (mounted) setState(() => _suggestions = []);
        return;
      }
      setState(() => _searching = true);
      final results = await _placeSearch.search(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion item) async {
    _center = LatLng(item.latitude, item.longitude);
    _safeMap.move(_center, 16);
    setState(() {
      _address = item.displayName;
      _searchController.text = item.displayName;
      _suggestions = [];
    });
    _searchFocus.unfocus();
  }

  Future<void> _confirm() async {
    if (_confirming) return;
    if (!OrderLocationPrefsValidators.hasCoordinates(_currentPick)) {
      AppMessages.showError(context, AppStrings.clientLocationRequired.tr());
      return;
    }

    setState(() => _confirming = true);
    try {
      var picked =
          await OrderLocationPrefs.ensureAddress(_currentPick, _geocoding);
      picked = OrderLocationPrefs.withResolvedAddress(picked);
      if (!mounted) return;
      await widget.onConfirmed(picked);
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: REdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              6.height,
              Text(
                AppStrings.inAppMapHint.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.commentColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        12.height,
        Padding(
          padding: REdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: AppStrings.typeDestinationHint.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? Padding(
                      padding: REdgeInsets.all(12),
                      child: SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.textFieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Padding(
            padding: REdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12.r),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      item.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    onTap: () => _selectSuggestion(item),
                  );
                },
              ),
            ),
          ),
        12.height,
        Expanded(
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15,
                      onMapReady: _onMapReady,
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd) {
                          setState(
                            () => _center = _mapController.camera.center,
                          );
                          _resolveAddress();
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: MapStyleConfig.tileUrlTemplate,
                        subdomains: MapStyleConfig.tileSubdomains,
                        userAgentPackageName:
                            MapStyleConfig.userAgentPackageName,
                        maxZoom: 19,
                      ),
                    ],
                  ),
                  IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 28.h),
                        child: Icon(
                          Icons.location_on,
                          size: 44.r,
                          color: AppColors.primaryColor,
                          shadows: const [
                            Shadow(blurRadius: 8, color: Colors.black26),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8.w,
                    bottom: 8.h,
                    child: FloatingActionButton.small(
                      heroTag: 'gps_${widget.title}',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      onPressed: _loadingGps ? null : () => _goToCurrentLocation(),
                      child: _loadingGps
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        12.height,
        Padding(
          padding: REdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loadingAddress)
                const Center(child: CircularProgressIndicator())
              else if (_address != null && _address!.isNotEmpty)
                Container(
                  padding: REdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFillColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 20.r,
                        color: AppColors.primaryColor,
                      ),
                      8.width,
                      Expanded(
                        child: Text(
                          _address!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              12.height,
              CustomButton.filled(
                text: widget.confirmLabel,
                onTap: _confirming ? null : _confirm,
                enabled: !_confirming,
                height: 52.h,
              ),
              if (_confirming) ...[
                12.height,
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
