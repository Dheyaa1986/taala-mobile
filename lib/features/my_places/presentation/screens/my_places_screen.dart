import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/taala_map_models.dart';
import 'package:taal/core/maps/widgets/iraq_offline_map_button.dart';
import 'package:taal/core/maps/widgets/taala_map_view.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/my_places/data/my_place_item.dart';
import 'package:taal/features/my_places/data/my_places_repository.dart';
import 'package:taal/features/my_places/presentation/my_place_ui.dart';
import 'package:taal/features/my_places/presentation/widgets/explore_around_sheet.dart';
import 'package:taal/features/service_orders/presentation/screens/provider_in_app_navigation_screen.dart';

enum _PlacesFilter { all, places, alerts }

class MyPlacesScreen extends StatefulWidget {
  const MyPlacesScreen({super.key});

  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen>
    with TaalaOfflineMapMixin {
  final _searchController = TextEditingController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _placeSearch = getIt<PlaceSearchService>();
  final _repository = getIt<MyPlacesRepository>();
  final _routing = getIt<TaalaRoutingService>();

  List<MyPlaceItem> _items = [];
  List<PlaceSuggestion> _suggestions = [];
  List<LatLng> _previewRoute = [];
  Timer? _searchDebounce;
  bool _searching = false;
  bool _tabActive = false;
  _PlacesFilter _filter = _PlacesFilter.all;
  LatLng _center = MapsHelper.defaultCenter;
  LatLng? _myLocation;
  double? _myHeading;
  Timer? _locationTimer;
  MyPlaceItem? _selected;
  MyPlaceItem? _searchPin;
  List<PlaceSuggestion> _exploreResults = [];
  int _cameraRevision = 0;
  bool _followCamera = false;

  List<MyPlaceItem> get _visibleItems {
    return _items.where((item) {
      return switch (_filter) {
        _PlacesFilter.all => true,
        _PlacesFilter.places => !item.isAlert,
        _PlacesFilter.alerts => item.isAlert,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.of(context);
    if (active && !_tabActive) {
      _tabActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
        unawaited(_goToCurrentLocation(showError: false));
        _locationTimer ??= Timer.periodic(const Duration(seconds: 2), (_) {
          unawaited(_refreshMyLocationMarker());
        });
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _locationTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _repository.loadAll();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {}
  }

  void _onMapReady() {
    unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
  }

  void _moveCameraTo(LatLng point) {
    _center = point;
    _followCamera = true;
    _cameraRevision++;
  }

  Future<void> _goToCurrentLocation({bool showError = true}) async {
    try {
      final reading = await _deviceLocation.getNavigationReading();
      if (!mounted) return;
      if (reading == null) {
        if (showError) {
          AppMessages.showError(
            context,
            AppStrings.locationPermissionDenied.tr(),
          );
        }
        return;
      }
      _myLocation = LatLng(reading.latitude, reading.longitude);
      if (reading.hasValidHeading) {
        _myHeading = reading.heading;
      }
      _moveCameraTo(_myLocation!);
      unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
      setState(() {});
    } catch (_) {}
  }

  Future<void> _refreshMyLocationMarker() async {
    if (!_tabActive) return;
    final reading = await _deviceLocation.getNavigationReading();
    if (!mounted || reading == null) return;
    setState(() {
      _myLocation = LatLng(reading.latitude, reading.longitude);
      if (reading.hasValidHeading) {
        _myHeading = reading.heading;
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      unawaited(_runSearch(value));
    });
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await _placeSearch.search(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _searching = false;
    });
  }

  void _applySuggestion(PlaceSuggestion suggestion, {bool save = false}) {
    final title = suggestion.displayName.split(',').first;
    _moveCameraTo(LatLng(suggestion.latitude, suggestion.longitude));
    _searchController.text = suggestion.displayName;
    setState(() {
      _suggestions = [];
      _selected = null;
      _searchPin = MyPlaceItem(
        id: 'search-pin',
        kind: MyPlaceKinds.place,
        category: MyPlaceCategories.other,
        title: title,
        latitude: suggestion.latitude,
        longitude: suggestion.longitude,
        address: suggestion.displayName,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );
    });
    unawaited(_previewRouteTo(_searchPin!));
    if (save) {
      unawaited(
        _openEditor(
          isAlert: false,
          presetTitle: title,
          latitude: suggestion.latitude,
          longitude: suggestion.longitude,
        ),
      );
    }
  }

  Future<void> _openEditor({
    required bool isAlert,
    MyPlaceItem? existing,
    String? presetCategory,
    String? presetTitle,
    double? latitude,
    double? longitude,
  }) {
    final lat = latitude ?? existing?.latitude ?? _center.latitude;
    final lng = longitude ?? existing?.longitude ?? _center.longitude;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _MyPlaceEditorSheet(
          isAlert: isAlert,
          initial: existing,
          presetCategory: presetCategory,
          presetTitle: presetTitle,
          latitude: lat,
          longitude: lng,
          geocoding: _geocoding,
          onSave: (item) async {
            final next = await _repository.upsert(item);
            if (!mounted) return;
            setState(() {
              _items = next;
              _selected = item;
              _moveCameraTo(LatLng(item.latitude, item.longitude));
            });
            AppMessages.showSuccess(context, AppStrings.myPlacesSaved.tr());
            unawaited(_previewRouteTo(item));
          },
        );
      },
    );
  }

  Future<void> _saveCurrentLocation() async {
    await _goToCurrentLocation();
    if (!mounted) return;
    final here = _myLocation;
    if (here == null) return;
    await _openEditor(
      isAlert: false,
      latitude: here.latitude,
      longitude: here.longitude,
    );
  }

  Future<void> _quickSave(String category) async {
    await _goToCurrentLocation(showError: false);
    if (!mounted) return;
    final here = _myLocation ?? _center;
    final existing = _items.cast<MyPlaceItem?>().firstWhere(
          (item) => item?.category == category,
          orElse: () => null,
        );
    await _openEditor(
      isAlert: false,
      existing: existing,
      presetCategory: category,
      presetTitle: myPlaceCategoryLabel(category),
      latitude: here.latitude,
      longitude: here.longitude,
    );
  }

  void _focusItem(MyPlaceItem item) {
    _moveCameraTo(LatLng(item.latitude, item.longitude));
    setState(() {
      _selected = item;
      _searchPin = null;
    });
    unawaited(_previewRouteTo(item));
  }

  Future<void> _previewRouteTo(MyPlaceItem item) async {
    final from = _myLocation;
    if (from == null) {
      setState(() => _previewRoute = []);
      return;
    }
    final points = await _routing.fetchDrivingRoute(
      from,
      LatLng(item.latitude, item.longitude),
    );
    if (!mounted) return;
    setState(() => _previewRoute = points);
  }

  Future<void> _delete(MyPlaceItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(AppStrings.myPlacesDeleteConfirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final next = await _repository.remove(item.id);
    if (!mounted) return;
    setState(() {
      _items = next;
      _previewRoute = [];
      if (_selected?.id == item.id) _selected = null;
    });
  }

  void _navigateTo(MyPlaceItem item) {
    _navigateToCoords(
      latitude: item.latitude,
      longitude: item.longitude,
      title: item.title,
    );
  }

  void _navigateToCoords({
    required double latitude,
    required double longitude,
    String? title,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ProviderInAppNavigationScreen(
          args: ProviderInAppNavigationArgs(
            targetLatitude: latitude,
            targetLongitude: longitude,
            targetTitle: title,
          ),
        ),
      ),
    );
  }

  Future<void> _openExplore() async {
    await _goToCurrentLocation(showError: false);
    if (!mounted) return;
    final origin = _myLocation ?? _center;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ExploreAroundSheet(
          latitude: origin.latitude,
          longitude: origin.longitude,
          placeSearch: _placeSearch,
          onResults: (results) {
            if (!mounted) return;
            setState(() {
              _exploreResults = results;
              if (results.isNotEmpty) {
                _center = LatLng(
                  results.first.latitude,
                  results.first.longitude,
                );
                _followCamera = true;
                _cameraRevision++;
              }
            });
          },
          onPick: (place) {
            Navigator.pop(context);
            _applySuggestion(place);
          },
        );
      },
    );
    if (!mounted) return;
    setState(() => _exploreResults = []);
  }

  Future<void> _openList() async {
    final selected = await showModalBottomSheet<MyPlaceItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final items = _visibleItems;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    AppStrings.myPlacesList.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text(AppStrings.myPlacesEmpty.tr()))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: Icon(
                                myPlaceIcon(item.category),
                                color: myPlaceColor(item),
                              ),
                              title: Text(item.title),
                              subtitle: (item.address ?? '').isEmpty
                                  ? null
                                  : Text(
                                      item.address!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) _focusItem(selected);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myPlaces.tr()),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IraqOfflineMapButton(
            iconOnly: true,
            onDownloaded: () => unawaited(
              refreshOfflineMapPath(
                _center.latitude,
                _center.longitude,
              ),
            ),
          ),
          IconButton(
            tooltip: AppStrings.myPlacesList.tr(),
            onPressed: () => unawaited(_openList()),
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: !_tabActive
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildMap(tokens),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Column(
                    children: [
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12.r),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: AppStrings.myPlacesSearchHint.tr(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searching
                                ? Padding(
                                    padding: EdgeInsets.all(12.r),
                                    child: SizedBox(
                                      width: 16.r,
                                      height: 16.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : (_searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _suggestions = []);
                                        },
                                      )),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          constraints: BoxConstraints(maxHeight: 220.h),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                leading: const Icon(Icons.place_outlined),
                                title: Text(
                                  suggestion.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.bookmark_add_outlined,
                                  ),
                                  onPressed: () => _applySuggestion(
                                    suggestion,
                                    save: true,
                                  ),
                                ),
                                onTap: () => _applySuggestion(suggestion),
                              );
                            },
                          ),
                        ),
                      8.height,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: AppStrings.myPlacesFilterAll.tr(),
                              selected: _filter == _PlacesFilter.all,
                              onTap: () => setState(
                                () => _filter = _PlacesFilter.all,
                              ),
                            ),
                            _FilterChip(
                              label: AppStrings.myPlacesFilterPlaces.tr(),
                              selected: _filter == _PlacesFilter.places,
                              onTap: () => setState(
                                () => _filter = _PlacesFilter.places,
                              ),
                            ),
                            _FilterChip(
                              label: AppStrings.myPlacesFilterAlerts.tr(),
                              selected: _filter == _PlacesFilter.alerts,
                              onTap: () => setState(
                                () => _filter = _PlacesFilter.alerts,
                              ),
                            ),
                            _FilterChip(
                              label: AppStrings.myPlacesHome.tr(),
                              selected: false,
                              onTap: () => unawaited(
                                _quickSave(MyPlaceCategories.home),
                              ),
                            ),
                            _FilterChip(
                              label: AppStrings.myPlacesWork.tr(),
                              selected: false,
                              onTap: () => unawaited(
                                _quickSave(MyPlaceCategories.work),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12.w,
                  bottom: 210.h,
                  child: FloatingActionButton.small(
                    heroTag: 'myPlacesGps',
                    onPressed: () => unawaited(_goToCurrentLocation()),
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h + context.bottomNavContentInset,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selected != null)
                        _SelectedCard(
                          item: _selected!,
                          onEdit: () => unawaited(
                            _openEditor(
                              isAlert: _selected!.isAlert,
                              existing: _selected,
                            ),
                          ),
                          onDelete: () => unawaited(_delete(_selected!)),
                          onClose: () => setState(() {
                            _selected = null;
                            _previewRoute = [];
                          }),
                        )
                      else if (_searchPin != null)
                        Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12.r),
                          color: tokens.surface,
                          child: ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(_searchPin!.title),
                            subtitle: Text(
                              _searchPin!.address ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (_selected != null || _searchPin != null) 8.height,
                      _mapActionButton(
                        label: AppStrings.departInApp.tr(),
                        onPressed: _departFromMap,
                      ),
                      8.height,
                      _mapActionButton(
                        label: AppStrings.exploreAround.tr(),
                        variant: TaalaButtonVariant.secondary,
                        onPressed: () => unawaited(_openExplore()),
                      ),
                      8.height,
                      _mapActionButton(
                        label: AppStrings.myPlacesSaveCurrent.tr(),
                        onPressed: () => unawaited(_saveCurrentLocation()),
                      ),
                      8.height,
                      _mapActionButton(
                        label: AppStrings.myPlacesSaveHere.tr(),
                        variant: TaalaButtonVariant.secondary,
                        onPressed: () => unawaited(
                          _openEditor(isAlert: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _departFromMap() {
    final selected = _selected;
    final pin = _searchPin;
    if (selected != null) {
      _navigateTo(selected);
      return;
    }
    if (pin != null) {
      _navigateTo(pin);
      return;
    }
    _navigateToCoords(
      latitude: _center.latitude,
      longitude: _center.longitude,
    );
  }

  Widget _mapActionButton({
    required String label,
    required VoidCallback onPressed,
    TaalaButtonVariant variant = TaalaButtonVariant.primary,
  }) {
    return Align(
      child: SizedBox(
        width: 210.w,
        child: TaalaButton(
          label: label,
          height: 40,
          variant: variant,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildMap(TaalaTokens tokens) {
    return TaalaMapView(
      initialCenter: _center,
      initialZoom: 16,
      cameraRevision: _cameraRevision,
      followPoint: _followCamera ? _center : null,
      offlineMapPath: offlineMapPath,
      offlineMapPaths: offlineMapPaths,
      onMapReady: _onMapReady,
      onTap: (_, point) {
        setState(() {
          _center = point;
          _followCamera = false;
          _selected = null;
          _searchPin = null;
          _previewRoute = [];
        });
      },
      onLongPress: (_, point) {
        setState(() {
          _center = point;
          _followCamera = false;
        });
        unawaited(_openEditor(
          isAlert: false,
          latitude: point.latitude,
          longitude: point.longitude,
        ));
      },
      onMoved: (point) {
        _center = point;
        _followCamera = false;
      },
      polylines: [
        if (_previewRoute.length >= 2)
          TaalaMapPolyline(
            points: _previewRoute,
            color: MapStyleConfig.routeColor,
            width: MapStyleConfig.routeWidth,
          ),
      ],
      markers: [
        if (_myLocation != null)
          TaalaMapMarker(
            point: _myLocation!,
            color: MapStyleConfig.routeColor,
            headingDegrees: _myHeading ?? 0,
          ),
        TaalaMapMarker(
          point: _searchPin != null
              ? LatLng(_searchPin!.latitude, _searchPin!.longitude)
              : _center,
          color: tokens.primary,
          icon: Icons.add_location_alt,
          iconSize: 36,
          label: AppStrings.myPlacesAddHere.tr(),
        ),
        ..._exploreResults.map(
          (place) => TaalaMapMarker(
            point: LatLng(place.latitude, place.longitude),
            color: tokens.primary,
            icon: Icons.place,
            iconSize: 28,
            onTap: () => _applySuggestion(place),
          ),
        ),
        ..._visibleItems.map(
          (item) => TaalaMapMarker(
            point: LatLng(item.latitude, item.longitude),
            color: myPlaceColor(item),
            icon: myPlaceIcon(item.category),
            iconSize: 28,
            livePulse: true,
            onTap: () => _focusItem(item),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 6.w),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  final MyPlaceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12.r),
      color: tokens.surface,
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(myPlaceIcon(item.category), color: myPlaceColor(item)),
                8.width,
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              myPlaceCategoryLabel(item.category),
              style: TextStyle(fontSize: 12.sp, color: tokens.textSecondary),
            ),
            if ((item.address ?? '').isNotEmpty)
              Text(
                item.address!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: tokens.textSecondary,
                ),
              ),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPlaceEditorSheet extends StatefulWidget {
  const _MyPlaceEditorSheet({
    required this.isAlert,
    required this.latitude,
    required this.longitude,
    required this.geocoding,
    required this.onSave,
    this.initial,
    this.presetCategory,
    this.presetTitle,
  });

  final bool isAlert;
  final double latitude;
  final double longitude;
  final ReverseGeocodingService geocoding;
  final Future<void> Function(MyPlaceItem item) onSave;
  final MyPlaceItem? initial;
  final String? presetCategory;
  final String? presetTitle;

  @override
  State<_MyPlaceEditorSheet> createState() => _MyPlaceEditorSheetState();
}

class _MyPlaceEditorSheetState extends State<_MyPlaceEditorSheet> {
  late final TextEditingController _title;
  late String _category;
  String? _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
      text: widget.initial?.title ?? widget.presetTitle ?? '',
    );
    _category = widget.initial?.category ??
        widget.presetCategory ??
        (widget.isAlert ? MyPlaceCategories.note : MyPlaceCategories.other);
    unawaited(_loadAddress());
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final address = await widget.geocoding.resolveAddress(
      widget.latitude,
      widget.longitude,
    );
    if (!mounted) return;
    setState(() => _address = address);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      AppMessages.showError(context, AppStrings.myPlacesNameRequired.tr());
      return;
    }
    setState(() => _saving = true);
    try {
      final item = MyPlaceItem(
        id: widget.initial?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        kind: widget.isAlert ? MyPlaceKinds.alert : MyPlaceKinds.place,
        category: _category,
        title: title,
        latitude: widget.latitude,
        longitude: widget.longitude,
        address: _address,
        createdAtMs: widget.initial?.createdAtMs ??
            DateTime.now().millisecondsSinceEpoch,
      );
      await widget.onSave(item);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppMessages.showError(context, AppStrings.genericError.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final categories = widget.isAlert
        ? MyPlaceCategories.alertOptions
        : MyPlaceCategories.placeOptions;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        color: tokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.initial != null
                      ? AppStrings.myPlacesEdit.tr()
                      : widget.isAlert
                          ? AppStrings.myPlacesAddAlert.tr()
                          : AppStrings.myPlacesAddPlace.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                12.height,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: categories
                      .map(
                        (category) => ChoiceChip(
                          selected: _category == category,
                          label: Text(myPlaceCategoryLabel(category)),
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                      )
                      .toList(),
                ),
                12.height,
                TextField(
                  controller: _title,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: AppStrings.name.tr(),
                  ),
                  onSubmitted: (_) => unawaited(_save()),
                ),
                if ((_address ?? '').isNotEmpty) ...[
                  8.height,
                  Text(
                    _address!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
                16.height,
                TaalaButton(
                  label: AppStrings.save.tr(),
                  enabled: !_saving,
                  onPressed: _saving ? null : () => unawaited(_save()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
