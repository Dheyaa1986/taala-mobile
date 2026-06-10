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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (mapUrl != null && mapUrl!.isNotEmpty) {
          await getIt<CustomLauncher>().openUrl(mapUrl!);
          return;
        }
        await getIt<CustomLauncher>().openMaps(
          double.tryParse(lat ?? '0.0') ?? 0.0,
          double.tryParse(long ?? '0.0') ?? 0.0,
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
