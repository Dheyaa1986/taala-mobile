import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/features/my_places/data/my_place_item.dart';

IconData myPlaceIcon(String category) {
  return switch (category) {
    MyPlaceCategories.home => Icons.home,
    MyPlaceCategories.work => Icons.work,
    MyPlaceCategories.traffic => Icons.traffic,
    MyPlaceCategories.accident => Icons.car_crash,
    MyPlaceCategories.speedBump => Icons.speed,
    MyPlaceCategories.police => Icons.local_police_outlined,
    MyPlaceCategories.trafficLight => Icons.traffic_outlined,
    MyPlaceCategories.sign => Icons.signpost_outlined,
    MyPlaceCategories.camera => Icons.videocam_outlined,
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
    MyPlaceCategories.speedBump => AppStrings.myPlacesSpeedBump.tr(),
    MyPlaceCategories.police => AppStrings.myPlacesPolice.tr(),
    MyPlaceCategories.trafficLight => AppStrings.myPlacesTrafficLight.tr(),
    MyPlaceCategories.sign => AppStrings.myPlacesSign.tr(),
    MyPlaceCategories.camera => AppStrings.myPlacesCamera.tr(),
    MyPlaceCategories.closure => AppStrings.myPlacesClosure.tr(),
    MyPlaceCategories.hazard => AppStrings.myPlacesHazard.tr(),
    _ => AppStrings.myPlacesNote.tr(),
  };
}
