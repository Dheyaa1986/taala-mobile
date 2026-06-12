import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/location_picker_screen.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';

class MapLocationPickerField extends StatelessWidget {
  const MapLocationPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final PickedLocation? value;
  final ValueChanged<PickedLocation> onChanged;
  final String? Function(PickedLocation?)? validator;

  Future<void> _openPicker(BuildContext context) async {
    final result = await LocationPickerScreen.open(context, initial: value);
    if (result != null) {
      onChanged(result);
    }
  }

  Future<void> _previewOnMap() async {
    if (value == null) return;
    await getIt<CustomLauncher>().openUrl(value!.googleMapsUrl);
  }

  @override
  Widget build(BuildContext context) {
    final error = validator?.call(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: REdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.textFieldFillColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: error != null
                  ? AppColors.redColor
                  : AppColors.brandBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: AppColors.primaryColor,
                    size: 22.r,
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      AppStrings.mapLink.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightMainText,
                      ),
                    ),
                  ),
                ],
              ),
              12.height,
              if (value != null) ...[
                if (value!.address != null && value!.address!.isNotEmpty)
                  Text(
                    value!.address!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.lightMainText,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    AppStrings.locationPicked.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.commentColor,
                    ),
                  ),
                6.height,
                Text(
                  '${value!.lat}, ${value!.lng}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                  ),
                ),
                12.height,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.outlined(
                        text: AppStrings.viewOnMap.tr(),
                        onTap: _previewOnMap,
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: CustomButton.filled(
                        text: AppStrings.changeLocation.tr(),
                        onTap: () => _openPicker(context),
                      ),
                    ),
                  ],
                ),
              ] else
                CustomButton.filled(
                  text: AppStrings.pickLocation.tr(),
                  onTap: () => _openPicker(context),
                  height: 44.h,
                ),
            ],
          ),
        ),
        if (error != null) ...[
          6.height,
          Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.redColor,
            ),
          ),
        ],
      ],
    );
  }
}
