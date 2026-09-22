import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/offline/map_offline_manager.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/provider_call_button.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/design_system/tokens/taala_shadows.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';
import 'package:taal/features/guest/presentation/widgets/guest_help_request_sheet.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_map_point.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/app_info/presentation/widgets/legal_links_row.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_fab.dart';
import 'package:taal/features/home/client/presentation/widgets/rating_bar.dart';

class GuestMapScreen extends StatefulWidget {
  const GuestMapScreen({super.key});

  @override
  State<GuestMapScreen> createState() => _GuestMapScreenState();
}

class _GuestMapScreenState extends State<GuestMapScreen> {
  final _mapController = MapController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _repository = getIt<ProviderRepository>();

  late LatLng _center;
  String? _address;
  List<ServiceProviderModel> _providers = [];
  String? _selectedProviderId;
  bool _loadingGps = false;
  bool _loadingAddress = false;
  bool _loadingProviders = false;
  String? _error;
  String? _offlineMapPath;

  @override
  void initState() {
    super.initState();
    _center = const LatLng(
      MapStyleConfig.defaultLatitude,
      MapStyleConfig.defaultLongitude,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    unawaited(_refreshOfflineMapPath());
  }

  Future<void> _refreshOfflineMapPath() async {
    final path = await getIt<MapOfflineManager>().localMapPathFor(
      _center.latitude,
      _center.longitude,
    );
    if (!mounted) return;
    setState(() => _offlineMapPath = path);
  }

  Future<void> _bootstrap() async {
    await _goToCurrentLocation(silent: true);
    if (!mounted) return;
    if (_center.latitude == MapStyleConfig.defaultLatitude &&
        _center.longitude == MapStyleConfig.defaultLongitude) {
      await _loadProviders();
    }
  }

  Future<void> _goToCurrentLocation({bool silent = false}) async {
    if (!silent) setState(() => _loadingGps = true);
    final location = await _deviceLocation.getCurrentLocation();
    if (!mounted) return;

    if (location != null) {
      _center = LatLng(location.latitude, location.longitude);
      _mapController.move(_center, MapStyleConfig.defaultZoom);
      await _resolveAddress();
      await _refreshOfflineMapPath();
      await _loadProviders();
    }

    if (!silent) setState(() => _loadingGps = false);
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

  Future<void> _onMapMoved() async {
    _center = _mapController.camera.center;
    await Future.wait([
      _resolveAddress(),
      _refreshOfflineMapPath(),
      _loadProviders(),
    ]);
  }

  Future<void> _loadProviders() async {
    setState(() {
      _loadingProviders = true;
      _error = null;
    });

    final result = await _repository.getGuestNearbyProviders(
      latitude: _center.latitude,
      longitude: _center.longitude,
      limit: 20,
    );

    if (!mounted) return;

    result.fold(
      (error) => setState(() {
        _loadingProviders = false;
        _error = error.message;
        _providers = [];
      }),
      (providers) => setState(() {
        _loadingProviders = false;
        _providers = providers;
        _error = null;
      }),
    );
  }

  void _openLogin({bool? asProvider}) {
    context.pushNamed(Routes.login, extra: asProvider);
  }

  void _requestHelp() {
    showGuestHelpRequestSheet(
      context,
      location: PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
      providerId: _selectedProviderId,
    ).then((completed) {
      if (completed == true && mounted) {
        context.goNamed(Routes.home);
      }
    });
  }

  List<Marker> _providerMarkers(TaalaTokens tokens) {
    return _providers.map((provider) {
      final point = provider.mapPoint;
      if (point == null) return null;
      final isSelected = provider.id == _selectedProviderId;

      return Marker(
        point: point,
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => setState(() => _selectedProviderId = provider.id),
          child: Icon(
            Icons.handyman_rounded,
            size: isSelected ? 40 : 34,
            color: isSelected ? tokens.primary : tokens.textPrimary,
            shadows: const [
              Shadow(blurRadius: 8, color: Colors.black26),
            ],
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      floatingActionButton: const SupportWhatsAppFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: MapStyleConfig.defaultZoom,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _onMapMoved();
                }
              },
            ),
            children: [
              HybridMapTileLayer(offlineMapPath: _offlineMapPath),
              MarkerLayer(markers: _providerMarkers(tokens)),
            ],
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36.h),
                child: Icon(
                  Icons.location_on,
                  size: 52.r,
                  color: tokens.primary,
                  shadows: const [
                    Shadow(blurRadius: 10, color: Colors.black26),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                const LangPopup(),
                8.width,
                Expanded(
                  child: Container(
                    padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: TaalaShadows.soft(brightness),
                    ),
                    child: Text(
                      AppStrings.guestMapHint.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ),
                8.width,
                Material(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openLogin(),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: TaalaShadows.soft(brightness),
                      ),
                      padding: REdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Text(
                        AppStrings.login.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.primary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.sizeOf(context).height * 0.40 + 8.h,
            child: const LegalLinksRow(),
          ),
          Positioned(
            right: 16.w,
            bottom: MediaQuery.sizeOf(context).height * 0.42,
            child: FloatingActionButton(
              heroTag: 'guest_gps',
              backgroundColor: tokens.surface,
              foregroundColor: tokens.primary,
              onPressed: _loadingGps ? null : _goToCurrentLocation,
              child: _loadingGps
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.40,
            minChildSize: 0.36,
            maxChildSize: 0.78,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: TaalaTokens.of(context).surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: TaalaShadows.soft(Theme.of(context).brightness),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: REdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    24 + context.safeBottomInset,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: tokens.borderSubtle,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    16.height,
                    Text(
                      AppStrings.guestMapTitle.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                    ),
                    8.height,
                    if (_loadingAddress)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (_address != null && _address!.isNotEmpty)
                      Text(
                        _address!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    16.height,
                    TaalaButton(
                      label: AppStrings.requestHelp.tr(),
                      onPressed: _requestHelp,
                      height: 48,
                    ),
                    12.height,
                    TaalaButton(
                      label: AppStrings.iAmProvider.tr(),
                      variant: TaalaButtonVariant.secondary,
                      onPressed: () => _openLogin(asProvider: true),
                      height: 48,
                    ),
                    20.height,
                    Row(
                      children: [
                        Text(
                          AppStrings.nearestProviders.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: tokens.textPrimary,
                              ),
                        ),
                        const Spacer(),
                        if (_loadingProviders)
                          SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                    12.height,
                    if (_error != null)
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.error,
                            ),
                      )
                    else if (!_loadingProviders && _providers.isEmpty)
                      Text(
                        AppStrings.noProvidersNearby.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                      )
                    else
                      ..._providers.map(
                        (provider) => _GuestProviderTile(
                          provider: provider,
                          isSelected: provider.id == _selectedProviderId,
                          clientLatitude: _center.latitude,
                          clientLongitude: _center.longitude,
                          onTap: () {
                            setState(() => _selectedProviderId = provider.id);
                            final point = provider.mapPoint;
                            if (point != null) {
                              _mapController.move(point, 15);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GuestProviderTile extends StatelessWidget {
  const _GuestProviderTile({
    required this.provider,
    required this.isSelected,
    required this.clientLatitude,
    required this.clientLongitude,
    required this.onTap,
  });

  final ServiceProviderModel provider;
  final bool isSelected;
  final double clientLatitude;
  final double clientLongitude;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: isSelected ? tokens.primarySoft : tokens.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.cardRadius),
          child: Container(
            padding: REdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.cardRadius),
              border: Border.all(
                color: isSelected ? tokens.primary : tokens.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: TaalaShadows.soft(brightness),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.handyman_rounded,
                  color: tokens.primary,
                  size: 28.r,
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                      ),
                      if (provider.services.isNotEmpty) ...[
                        4.height,
                        Text(
                          provider.services.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.textSecondary,
                              ),
                        ),
                      ],
                      6.height,
                      RatingRow(
                        rating: provider.rate ?? 0,
                        totalRatings: provider.totalRatings ?? 0,
                      ),
                      if (provider.distanceKm != null) ...[
                        6.height,
                        Text(
                          '${provider.distanceKm!.toStringAsFixed(1)} كم'
                          '${provider.etaMinutes != null ? ' • ${provider.etaMinutes} ${AppStrings.minutes.tr()}' : ''}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: tokens.primary,
                              ),
                        ),
                      ],
                      if (provider.callAvailable && provider.id != null) ...[
                        10.height,
                        ProviderCallButton(
                          providerId: provider.id!,
                          latitude: clientLatitude,
                          longitude: clientLongitude,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
