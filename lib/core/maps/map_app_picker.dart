import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';

import '../app_config/app_strings.dart';
import '../extensions/space_extension.dart';
import '../widgets/bottom_sheets/custom_bottom_sheet.dart';

class MapAppPicker {
  static Future<AvailableMap?> pick(BuildContext context) async {
    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty || maps.length == 1) return maps.firstOrNull;

    if (!context.mounted) return null;

    return showModalBottomSheet<AvailableMap>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return CustomBottomSheet(
          isScrollControlled: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: REdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  AppStrings.chooseMapApp.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...maps.map(
                (map) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SvgPicture.asset(
                      map.icon,
                      package: 'map_launcher',
                      width: 36.r,
                      height: 36.r,
                    ),
                  ),
                  title: Text(
                    map.mapName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetContext, map),
                ),
              ),
              8.height,
            ],
          ),
        );
      },
    );
  }
}
