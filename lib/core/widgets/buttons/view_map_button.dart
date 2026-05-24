import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_strings.dart';
import '../../custom_launcher/custom_launcher.dart';
import '../../di/service_locator.dart';

class ViewMapButton extends StatelessWidget {
  const ViewMapButton(
      {super.key, required this.lat, required this.long, required this.name});
  final String? lat;
  final String? long;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await getIt<CustomLauncher>().openMaps(
            double.tryParse(lat ?? '0.0') ?? 0.0,
            double.tryParse(long ?? '0.0') ?? 0.0,
            name ?? '');
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
