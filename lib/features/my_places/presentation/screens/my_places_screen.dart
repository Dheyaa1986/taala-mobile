import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/maps_helper.dart';
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
import 'package:taal/core/maps/safe_map_controller.dart';
import 'package:taal/core/maps/taala_routing_service.dart';
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/live_map_marker.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/my_places/data/my_place_item.dart';
import 'package:taal/features/my_places/data/my_places_repository.dart';

enum _PlacesFilter { all, places, alerts }

class MyPlacesScreen extends StatefulWidget {
  const MyPlacesScreen({super.key});

  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen>
    with TaalaOfflineMapMixin {
  MapController? _mapController;
  SafeMapController? _safeMap;
  final _searchController = TextEditingController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _placeSearch = getIt<PlaceSearchService>();
  final _repository = getIt<MyPlacesRepository>();
  final _launcher = getIt<CustomLauncher>();
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
  MyPlaceItem? _selected;

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
      _mapController ??= MapController();
      _safeMap ??= SafeMapController(_mapController!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
        unawaited(_goToCurrentLocation(showError: false));
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
    _safeMap?.markReady();
    _safeMap?.move(_center, 14);
    unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
  }

  Future<void> _goToCurrentLocation({bool showError = true}) async {
    try {
      final current = await _deviceLocation.getCurrentLocation();
      if (!mounted) return;
      if (current == null) {
        if (showError) {
          AppMessages.showError(
            context,
            AppStrings.locationPermissionDenied.tr(),
          );
        }
        return;
      }
      _myLocation = LatLng(current.latitude, current.longitude);
      _center = _myLocation!;
      _safeMap?.move(_center, 16);
      unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
      setState(() {});
    } catch (_) {}
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
    _center = LatLng(suggestion.latitude, suggestion.longitude);
    _safeMap?.move(_center, 16);
    _searchController.text = suggestion.displayName;
    setState(() {
      _suggestions = [];
      _selected = null;
    });
    if (save) {
      unawaited(
        _openEditor(
          isAlert: false,
          presetTitle: suggestion.displayName.split(',').first,
        ),
      );
    }
  }

  Future<void> _openEditor({
    required bool isAlert,
    MyPlaceItem? existing,
    String? presetCategory,
    String? presetTitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _MyPlaceEditorSheet(
          isAlert: isAlert,
          initial: existing,
          presetCategory: presetCategory,
          presetTitle: presetTitle,
          latitude: existing?.latitude ?? _center.latitude,
          longitude: existing?.longitude ?? _center.longitude,
          geocoding: _geocoding,
          onSave: (item) async {
            final next = await _repository.upsert(item);
            if (!mounted) return;
            setState(() {
              _items = next;
              _selected = item;
            });
            _safeMap?.move(LatLng(item.latitude, item.longitude), 16);
            unawaited(_previewRouteTo(item));
          },
        );
      },
    );
  }

  Future<void> _quickSave(String category) async {
    final existing = _items.cast<MyPlaceItem?>().firstWhere(
          (item) => item?.category == category,
          orElse: () => null,
        );
    if (existing != null) {
      _focusItem(existing);
      return;
    }
    await _openEditor(isAlert: false, presetCategory: category);
  }

  void _focusItem(MyPlaceItem item) {
    _center = LatLng(item.latitude, item.longitude);
    _safeMap?.move(_center, 16);
    setState(() => _selected = item);
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

  Future<void> _navigateTo(MyPlaceItem item) {
    return _launcher.openDirections(
      destinationLat: item.latitude,
      destinationLng: item.longitude,
      destinationTitle: item.title,
    );
  }

  Future<void> _openWaze(MyPlaceItem item) {
    return _launcher.openWazeDirections(
      destinationLat: item.latitude,
      destinationLng: item.longitude,
      destinationTitle: item.title,
      originLat: _myLocation?.latitude,
      originLng: _myLocation?.longitude,
    );
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
                              subtitle: Text(
                                item.address ?? item.details ?? '',
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
    final mapController = _mapController;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myPlaces.tr()),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: AppStrings.myPlacesList.tr(),
            onPressed: () => unawaited(_openList()),
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: mapController == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 14,
                    onMapReady: _onMapReady,
                    onTap: (_, point) {
                      setState(() {
                        _center = point;
                        _selected = null;
                        _previewRoute = [];
                      });
                    },
                    onLongPress: (_, point) {
                      setState(() => _center = point);
                      unawaited(_openEditor(isAlert: false));
                    },
                  ),
                  children: [
                    HybridMapTileLayer(offlineMapPath: offlineMapPath),
                    if (_previewRoute.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _previewRoute,
                            color: MapStyleConfig.routeCasingColor,
                            strokeWidth: MapStyleConfig.routeCasingWidth,
                          ),
                          Polyline(
                            points: _previewRoute,
                            color: MapStyleConfig.routeColor,
                            strokeWidth: MapStyleConfig.routeWidth,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _center,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.add_location_alt,
                            color: tokens.primary,
                            size: 36,
                          ),
                        ),
                        ..._visibleItems.map(
                          (item) => Marker(
                            point: LatLng(item.latitude, item.longitude),
                            width: 48,
                            height: 48,
                            child: GestureDetector(
                              onTap: () => _focusItem(item),
                              child: LiveMapMarker(
                                icon: myPlaceIcon(item.category),
                                color: myPlaceColor(item),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                                  icon: const Icon(Icons.bookmark_add_outlined),
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
                  bottom: 118.h,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'myPlacesListFab',
                        onPressed: () => unawaited(_openList()),
                        child: const Icon(Icons.list),
                      ),
                      8.height,
                      FloatingActionButton.small(
                        heroTag: 'myPlacesGps',
                        onPressed: () => unawaited(_goToCurrentLocation()),
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selected != null)
                        _SelectedCard(
                          item: _selected!,
                          onNavigate: () => unawaited(_navigateTo(_selected!)),
                          onWaze: () => unawaited(_openWaze(_selected!)),
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
                        ),
                      if (_selected != null) 8.height,
                      Row(
                        children: [
                          Expanded(
                            child: TaalaButton(
                              label: AppStrings.myPlacesAddPlace.tr(),
                              height: 48,
                              onPressed: () => unawaited(
                                _openEditor(isAlert: false),
                              ),
                            ),
                          ),
                          8.width,
                          Expanded(
                            child: TaalaButton(
                              label: AppStrings.myPlacesAddAlert.tr(),
                              height: 48,
                              variant: TaalaButtonVariant.secondary,
                              onPressed: () => unawaited(
                                _openEditor(isAlert: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

IconData myPlaceIcon(String category) {
  return switch (category) {
    MyPlaceCategories.home => Icons.home,
    MyPlaceCategories.work => Icons.work,
    MyPlaceCategories.traffic => Icons.traffic,
    MyPlaceCategories.accident => Icons.car_crash,
    MyPlaceCategories.closure => Icons.block,
    MyPlaceCategories.hazard => Icons.warning_amber_rounded,
    MyPlaceCategories.note => Icons.campaign,
    _ => Icons.place,
  };
}

Color myPlaceColor(MyPlaceItem item) {
  if (item.isAlert) return const Color(0xFFE65100);
  return switch (item.category) {
    MyPlaceCategories.home => const Color(0xFF2E7D32),
    MyPlaceCategories.work => const Color(0xFF1565C0),
    _ => MapStyleConfig.routeColor,
  };
}

String myPlaceCategoryLabel(String category) {
  return switch (category) {
    MyPlaceCategories.home => AppStrings.myPlacesHome.tr(),
    MyPlaceCategories.work => AppStrings.myPlacesWork.tr(),
    MyPlaceCategories.other => AppStrings.myPlacesOther.tr(),
    MyPlaceCategories.traffic => AppStrings.myPlacesTraffic.tr(),
    MyPlaceCategories.accident => AppStrings.myPlacesAccident.tr(),
    MyPlaceCategories.closure => AppStrings.myPlacesClosure.tr(),
    MyPlaceCategories.hazard => AppStrings.myPlacesHazard.tr(),
    _ => AppStrings.myPlacesNote.tr(),
  };
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
    required this.onNavigate,
    required this.onWaze,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  final MyPlaceItem item;
  final VoidCallback onNavigate;
  final VoidCallback onWaze;
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
            if ((item.details ?? '').isNotEmpty)
              Text(item.details!, style: TextStyle(fontSize: 13.sp)),
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
              children: [
                Expanded(
                  child: TaalaButton(
                    label: AppStrings.myPlacesNavigate.tr(),
                    height: 44,
                    onPressed: onNavigate,
                  ),
                ),
                8.width,
                Expanded(
                  child: TaalaButton(
                    label: AppStrings.myPlacesOpenWaze.tr(),
                    height: 44,
                    variant: TaalaButtonVariant.secondary,
                    onPressed: onWaze,
                  ),
                ),
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
  late final TextEditingController _details;
  late String _category;
  String? _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
      text: widget.initial?.title ?? widget.presetTitle ?? '',
    );
    _details = TextEditingController(text: widget.initial?.details ?? '');
    _category = widget.initial?.category ??
        widget.presetCategory ??
        (widget.isAlert ? MyPlaceCategories.note : MyPlaceCategories.other);
    unawaited(_loadAddress());
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
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
    var title = _title.text.trim();
    if (title.isEmpty) {
      title = myPlaceCategoryLabel(_category);
    }
    setState(() => _saving = true);
    final item = MyPlaceItem(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      kind: widget.isAlert ? MyPlaceKinds.alert : MyPlaceKinds.place,
      category: _category,
      title: title,
      details: _details.text.trim().isEmpty ? null : _details.text.trim(),
      latitude: widget.latitude,
      longitude: widget.longitude,
      address: _address,
      createdAtMs: widget.initial?.createdAtMs ??
          DateTime.now().millisecondsSinceEpoch,
    );
    await widget.onSave(item);
    if (!mounted) return;
    Navigator.pop(context);
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
                  decoration: InputDecoration(
                    labelText: AppStrings.name.tr(),
                  ),
                ),
                12.height,
                TextField(
                  controller: _details,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppStrings.myPlacesDetails.tr(),
                  ),
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
