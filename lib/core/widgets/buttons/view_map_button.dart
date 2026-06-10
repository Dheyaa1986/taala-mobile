import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_strings.dart';
import '../../custom_launcher/custom_launcher.dart';
import '../../di/service_locator.dart';

class ViewMapButton extends StatelessWidget {
  const ViewMapButton({
    super.key,
    this.lat,
    this.long,
    this.name,
    this.mapUrl,
  });
  final String? lat;
  final String? long;
  final String? name;
  final String? mapUrl;

  bool get _hasMapUrl => mapUrl != null && mapUrl!.trim().isNotEmpty;

  bool get _hasCoordinates {
    final parsedLat = double.tryParse(lat ?? '');
    final parsedLng = double.tryParse(long ?? '');
    return parsedLat != null &&
        parsedLng != null &&
        (parsedLat != 0 || parsedLng != 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasMapUrl && !_hasCoordinates) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () async {
        if (_hasMapUrl) {
          await getIt<CustomLauncher>().openUrl(mapUrl!.trim());
          return;
        }
        await getIt<CustomLauncher>().openMaps(
          double.parse(lat!),
          double.parse(long!),
          name ?? '',
        );
      },
      child: Text(
        AppStrings.viewOnMap.tr(),
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
