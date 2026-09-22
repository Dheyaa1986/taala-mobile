import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/core/widgets/buttons/view_map_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/design_system/tokens/taala_shadows.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/widgets/add_location_sheet.dart';
import 'package:taal/features/home/provider/presentation/widgets/confirm_delete_dialog.dart';

import '../../../../../core/app_config/app_icons.dart';
import '../cubit/locations/location_cubit.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.model});
  final LocationModel model;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: TaalaShadows.soft(brightness),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgImageWidget(
            image: AppIcons.location,
            height: 24.h,
            width: 24.w,
          ),
          8.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    model.governorateName ?? model.governance?.name,
                    model.cityName ?? model.city?.name,
                  ].where((e) => e != null && e.isNotEmpty).join(', '),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                ),
                8.height,
                ViewMapButton(
                  mapUrl: model.mapLink,
                  lat: model.lat,
                  long: model.lng,
                  name: model.cityName ?? model.city?.name,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconButton.lightGreyBg(
                size: 32.r,
                icon: AppIcons.edit,
                onTap: () async {
                  await showLocationSheet(context, model: model).then(
                    (value) {
                      if (value != null && value is LocationModel) {
                        context.read<LocationCubit>().updateLocation(value);
                      }
                    },
                  );
                },
              ),
              8.width,
              CustomIconButton.lightGreyBg(
                size: 32.r,
                icon: AppIcons.delete,
                onTap: () async {
                  await showConfirmationDialog(
                    context: context,
                    title: AppStrings.deleteLocation.tr(),
                    message: AppStrings.deleteLocationSubtitle.tr(),
                    buttonColor: null,
                  ).then(
                    (value) {
                      if (value == true) {
                        AppMessages.showSuccess(
                          context,
                          AppStrings.deleteLocationSuccess.tr(),
                        );
                        context.read<LocationCubit>().deleteLocation(model);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
