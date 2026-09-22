import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/location_picker_screen.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/features/service_orders/presentation/widgets/dual_location_preview_map.dart';

class OrderDestinationPickerSection extends StatefulWidget {
  const OrderDestinationPickerSection({
    super.key,
    required this.clientLocation,
    required this.destination,
    required this.onDestinationChanged,
    this.showMapPreview = true,
  });

  final PickedLocation? clientLocation;
  final PickedLocation? destination;
  final ValueChanged<PickedLocation> onDestinationChanged;
  final bool showMapPreview;

  @override
  State<OrderDestinationPickerSection> createState() =>
      _OrderDestinationPickerSectionState();
}

class _OrderDestinationPickerSectionState
    extends State<OrderDestinationPickerSection> {
  final _placeSearch = getIt<PlaceSearchService>();
  final _controller = TextEditingController();
  final _searchFocus = FocusNode();
  List<PlaceSuggestion> _suggestions = [];
  bool _searching = false;
  Timer? _debounce;
  bool _syncingText = false;

  @override
  void initState() {
    super.initState();
    _syncFromDestination(widget.destination);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant OrderDestinationPickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination) {
      _syncFromDestination(widget.destination);
    }
  }

  void _syncFromDestination(PickedLocation? destination) {
    final text = destination?.address ?? '';
    if (_controller.text == text) return;
    _syncingText = true;
    _controller.text = text;
    _syncingText = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final result = await LocationPickerScreen.open(
      context,
      initial: widget.destination,
    );
    if (result == null || !mounted) return;
    widget.onDestinationChanged(result);
    _searchFocus.unfocus();
    setState(() => _suggestions = []);
  }

  void _onTextChanged() {
    if (_syncingText) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final query = _controller.text.trim();
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

  void _selectSuggestion(PlaceSuggestion item) {
    widget.onDestinationChanged(
      PickedLocation(
        latitude: item.latitude,
        longitude: item.longitude,
        address: item.displayName,
      ),
    );
    _searchFocus.unfocus();
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final showMap = widget.showMapPreview &&
        widget.clientLocation != null &&
        OrderLocationPrefsValidators.isValidDestination(widget.destination);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.whereToGo.tr(),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        6.height,
        Text(
          AppStrings.searchDestinationHint.tr(),
          style: TextStyle(
            fontSize: 12.sp,
            color: tokens.textSecondary,
            height: 1.4,
          ),
        ),
        12.height,
        TextField(
          controller: _controller,
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
            fillColor: tokens.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          8.height,
          Material(
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
        ] else if (_controller.text.trim().length >= 3 && !_searching) ...[
          8.height,
          Text(
            AppStrings.noPlaceResults.tr(),
            style: TextStyle(fontSize: 12.sp, color: tokens.textSecondary),
          ),
        ],
        12.height,
        TaalaButton(
          label: AppStrings.pickLocationOnMap.tr(),
          variant: TaalaButtonVariant.secondary,
          onPressed: _pickOnMap,
        ),
        if (showMap) ...[
          24.height,
          Text(
            AppStrings.mapPreview.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          12.height,
          DualLocationPreviewMap(
            origin: widget.clientLocation!,
            destination: widget.destination,
          ),
        ],
      ],
    );
  }
}
