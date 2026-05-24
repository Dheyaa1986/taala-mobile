import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/core/widgets/buttons/view_map_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
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
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgImageWidget(
              image: AppIcons.location,
              height: 24.h,
              width: 24.w,
            ),
            4.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model.governance?.name},${model.city?.name}' ?? '',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  8.height,
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  8.height,
                  ViewMapButton(
                    lat: model.lat,
                    long: model.lng,
                    name: '${model.governance?.name},${model.city?.name}',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomIconButton.lightGreyBg(
                      size: 32.r,
                      icon: AppIcons.edit,
                      onTap: () async {
                        await showLocationSheet(context, model: model).then(
                          (value) {
                            if (value != null && value is LocationModel) {
                              context
                                  .read<LocationCubit>()
                                  .updateLocation(value);
                            }
                          },
                        );
                      }),
                  8.width,
                  CustomIconButton.lightGreyBg(
                    size: 32.r,
                    icon: AppIcons.delete,
                    onTap: () async {
                      await showConfirmationDialog(
                              context: context,
                              title: AppStrings.deleteLocation.tr(),
                              message: AppStrings.deleteLocationSubtitle.tr(),
                              buttonColor: null)
                          .then(
                        (value) {
                          if (value == true) {
                            AppMessages.showSuccess(
                                context, AppStrings.deleteLocationSuccess.tr());
                            context.read<LocationCubit>().deleteLocation(model);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
Row(
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                model.title ?? '',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              12.height,
              Text(
                model.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              14.height,
              CustomButton(
                radius: Radius.circular(8.r),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                text: AppStrings.courseLink.tr(),
                onTap: () async {
                  CustomLauncher launcher = CustomLauncher();
                  await launcher.lunchUrl(model.link ?? '');
                },
              ),
            ],
          ),
        ],
      )*/
