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
import 'package:taal/core/maps/widgets/hybrid_map_tile_layer.dart';
import 'package:taal/core/maps/widgets/live_map_marker.dart';
import 'package:taal/core/maps/widgets/taala_offline_map_mixin.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/my_places/data/my_place_item.dart';
import 'package:taal/features/my_places/data/my_places_repository.dart';

class MyPlacesScreen extends StatefulWidget {
  const MyPlacesScreen({super.key});

  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen>
    with TaalaOfflineMapMixin {
  final _mapController = MapController();
  late final SafeMapController _safeMap = SafeMapController(_mapController);
  final _searchController = TextEditingController();
  final _deviceLocation = getIt<DeviceLocationService>();
  final _geocoding = getIt<ReverseGeocodingService>();
  final _placeSearch = getIt<PlaceSearchService>();
  final _repository = getIt<MyPlacesRepository>();
  final _launcher = getIt<CustomLauncher>();

  List<MyPlaceItem> _items = [];
  List<PlaceSuggestion> _suggestions = [];
  Timer? _searchDebounce;
  bool _searching = false;
  LatLng _center = MapsHelper.defaultCenter;
  MyPlaceItem? _selected;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    unawaited(_goToCurrentLocation(showError: false));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await _repository.loadAll();
    if (!mounted) return;
    setState(() => _items = items);
  }

  void _onMapReady() {
    _safeMap.markReady();
    _safeMap.move(_center, 14);
    unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
  }

  Future<void> _goToCurrentLocation({bool showError = true}) async {
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
    _center = LatLng(current.latitude, current.longitude);
    _safeMap.move(_center, 16);
    unawaited(refreshOfflineMapPath(_center.latitude, _center.longitude));
    setState(() {});
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

  void _applySuggestion(PlaceSuggestion suggestion) {
    _center = LatLng(suggestion.latitude, suggestion.longitude);
    _safeMap.move(_center, 16);
    _searchController.text = suggestion.displayName;
    setState(() {
      _suggestions = [];
      _selected = null;
    });
  }

  Future<void> _openEditor({required bool isAlert, MyPlaceItem? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _MyPlaceEditorSheet(
          isAlert: isAlert,
          initial: existing,
          latitude: existing?.latitude ?? _center.latitude,
          longitude: existing?.longitude ?? _center.longitude,
          geocoding: _geocoding,
          onSave: (item) async {
            final next = existing == null
                ? await _repository.add(item)
                : await _replace(item);
            if (!mounted) return;
            setState(() {
              _items = next;
              _selected = item;
            });
          },
        );
      },
    );
  }

  Future<List<MyPlaceItem>> _replace(MyPlaceItem item) async {
    final items = await _repository.loadAll();
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await _repository.saveAll(items);
    return items;
  }

  Future<void> _delete(MyPlaceItem item) async {
    final next = await _repository.remove(item.id);
    if (!mounted) return;
    setState(() {
      _items = next;
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

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myPlaces.tr()),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onMapReady: _onMapReady,
              onTap: (_, point) {
                setState(() {
                  _center = point;
                  _selected = null;
                });
              },
              onLongPress: (_, point) {
                setState(() => _center = point);
                unawaited(_openEditor(isAlert: false));
              },
            ),
            children: [
              HybridMapTileLayer(offlineMapPath: offlineMapPath),
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
                  ..._items.map(
                    (item) => Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = item),
                        child: LiveMapMarker(
                          icon: _iconFor(item.category),
                          color: _colorFor(item),
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
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(
                            suggestion.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _applySuggestion(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: 102.h,
            child: FloatingActionButton.small(
              heroTag: 'myPlacesGps',
              onPressed: () => unawaited(_goToCurrentLocation()),
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selected != null) _SelectedCard(
                  item: _selected!,
                  onNavigate: () => unawaited(_navigateTo(_selected!)),
                  onDelete: () => unawaited(_delete(_selected!)),
                  onClose: () => setState(() => _selected = null),
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

  static IconData _iconFor(String category) {
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

  static Color _colorFor(MyPlaceItem item) {
    if (item.isAlert) return const Color(0xFFE65100);
    return switch (item.category) {
      MyPlaceCategories.home => const Color(0xFF2E7D32),
      MyPlaceCategories.work => const Color(0xFF1565C0),
      _ => MapStyleConfig.routeColor,
    };
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({
    required this.item,
    required this.onNavigate,
    required this.onDelete,
    required this.onClose,
  });

  final MyPlaceItem item;
  final VoidCallback onNavigate;
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
  });

  final bool isAlert;
  final double latitude;
  final double longitude;
  final ReverseGeocodingService geocoding;
  final Future<void> Function(MyPlaceItem item) onSave;
  final MyPlaceItem? initial;

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
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _details = TextEditingController(text: widget.initial?.details ?? '');
    _category = widget.initial?.category ??
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
    final title = _title.text.trim();
    if (title.isEmpty) {
      AppMessages.showError(context, AppStrings.pleaseEnterName.tr());
      return;
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
                  widget.isAlert
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
                          label: Text(_categoryLabel(category)),
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

  String _categoryLabel(String category) {
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
}
