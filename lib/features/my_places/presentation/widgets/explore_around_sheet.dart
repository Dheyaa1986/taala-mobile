import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/maps/place_search_service.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class ExploreAroundCategory {
  const ExploreAroundCategory({
    required this.labelKey,
    required this.icon,
    required this.color,
    required this.overpassFilters,
  });

  final String labelKey;
  final IconData icon;
  final Color color;
  final List<String> overpassFilters;
}

const exploreAroundCategories = <ExploreAroundCategory>[
  ExploreAroundCategory(
    labelKey: AppStrings.exploreHospitals,
    icon: Icons.local_hospital,
    color: Color(0xFFE53935),
    overpassFilters: [
      '["amenity"="hospital"]',
      '["amenity"="clinic"]',
      '["healthcare"="hospital"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreRestaurants,
    icon: Icons.restaurant,
    color: Color(0xFFFB8C00),
    overpassFilters: [
      '["amenity"="restaurant"]',
      '["amenity"="fast_food"]',
      '["amenity"="cafe"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreCharging,
    icon: Icons.ev_station,
    color: Color(0xFF43A047),
    overpassFilters: ['["amenity"="charging_station"]'],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreFuel,
    icon: Icons.local_gas_station,
    color: Color(0xFF1E88E5),
    overpassFilters: ['["amenity"="fuel"]'],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreShopping,
    icon: Icons.shopping_bag,
    color: Color(0xFF8E24AA),
    overpassFilters: [
      '["shop"="supermarket"]',
      '["shop"="convenience"]',
      '["shop"="mall"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreBanks,
    icon: Icons.account_balance,
    color: Color(0xFF3949AB),
    overpassFilters: [
      '["amenity"="bank"]',
      '["amenity"="atm"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreMosques,
    icon: Icons.mosque,
    color: Color(0xFF00897B),
    overpassFilters: [
      '["amenity"="place_of_worship"]["religion"="muslim"]',
      '["amenity"="place_of_worship"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreTransit,
    icon: Icons.directions_bus,
    color: Color(0xFF039BE5),
    overpassFilters: [
      '["amenity"="bus_station"]',
      '["highway"="bus_stop"]',
      '["public_transport"="station"]',
    ],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.exploreParks,
    icon: Icons.park,
    color: Color(0xFF7CB342),
    overpassFilters: ['["leisure"="park"]'],
  ),
  ExploreAroundCategory(
    labelKey: AppStrings.explorePharmacies,
    icon: Icons.local_pharmacy,
    color: Color(0xFFD81B60),
    overpassFilters: ['["amenity"="pharmacy"]'],
  ),
];

class ExploreAroundSheet extends StatefulWidget {
  const ExploreAroundSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeSearch,
    required this.onResults,
    required this.onPick,
  });

  final double latitude;
  final double longitude;
  final PlaceSearchService placeSearch;
  final ValueChanged<List<PlaceSuggestion>> onResults;
  final ValueChanged<PlaceSuggestion> onPick;

  @override
  State<ExploreAroundSheet> createState() => _ExploreAroundSheetState();
}

class _ExploreAroundSheetState extends State<ExploreAroundSheet> {
  ExploreAroundCategory? _selected;
  bool _loading = false;
  List<PlaceSuggestion> _results = [];

  Future<void> _loadCategory(ExploreAroundCategory category) async {
    setState(() {
      _selected = category;
      _loading = true;
      _results = [];
    });
    widget.onResults(const []);
    final results = await widget.placeSearch.searchNearby(
      latitude: widget.latitude,
      longitude: widget.longitude,
      overpassFilter: category.overpassFilters.first,
      overpassFilters: category.overpassFilters,
    );
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
    widget.onResults(results);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.48,
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 8.h),
              child: Row(
                children: [
                  if (_selected != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selected = null;
                          _results = [];
                          _loading = false;
                        });
                        widget.onResults(const []);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: Text(
                      _selected == null
                          ? AppStrings.exploreAround.tr()
                          : _selected!.labelKey.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selected == null
                  ? GridView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: exploreAroundCategories.length,
                      itemBuilder: (context, index) {
                        final category = exploreAroundCategories[index];
                        return InkWell(
                          onTap: () => _loadCategory(category),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26.r,
                                backgroundColor:
                                    category.color.withValues(alpha: 0.15),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                category.labelKey.tr(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.sp),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _results.isEmpty
                          ? Center(child: Text(AppStrings.exploreEmpty.tr()))
                          : ListView.separated(
                              itemCount: _results.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final place = _results[index];
                                final meters = place.distanceMeters;
                                final subtitle = meters == null
                                    ? null
                                    : meters >= 1000
                                        ? '${(meters / 1000).toStringAsFixed(1)} ${AppStrings.exploreKm.tr()}'
                                        : '${meters.round()} ${AppStrings.exploreMeters.tr()}';
                                return ListTile(
                                  leading: Icon(
                                    _selected!.icon,
                                    color: _selected!.color,
                                  ),
                                  title: Text(
                                    place.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: subtitle == null
                                      ? null
                                      : Text(subtitle),
                                  onTap: () => widget.onPick(place),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
