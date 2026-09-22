import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/location_picker_screen.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

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
    final tokens = TaalaTokens.of(context);
    final error = validator?.call(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: REdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.surfaceMuted,
            borderRadius: BorderRadius.circular(tokens.inputRadius),
            border: Border.all(
              color: error != null ? tokens.error : tokens.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: tokens.primary,
                    size: 22.r,
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      AppStrings.mapLink.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textPrimary,
                          height: 1.4,
                        ),
                  )
                else
                  Text(
                    AppStrings.locationPicked.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                  ),
                6.height,
                Text(
                  '${value!.lat}, ${value!.lng}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                ),
                12.height,
                Row(
                  children: [
                    Expanded(
                      child: TaalaButton(
                        label: AppStrings.viewOnMap.tr(),
                        variant: TaalaButtonVariant.secondary,
                        height: 44,
                        onPressed: _previewOnMap,
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: TaalaButton(
                        label: AppStrings.changeLocation.tr(),
                        height: 44,
                        onPressed: () => _openPicker(context),
                      ),
                    ),
                  ],
                ),
              ] else
                TaalaButton(
                  label: AppStrings.pickLocation.tr(),
                  onPressed: () => _openPicker(context),
                  height: 44,
                ),
            ],
          ),
        ),
        if (error != null) ...[
          6.height,
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.error,
                ),
          ),
        ],
      ],
    );
  }
}
