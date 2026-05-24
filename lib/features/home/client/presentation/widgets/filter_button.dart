import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/client/presentation/widgets/filter_providers_sheet.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/options/pagination_options.dart';

class FilterServiceButton extends StatelessWidget {
  const FilterServiceButton({super.key, });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showFilterProvidersSheet(context,
                model: context.read<ServiceProvidersCubit>().filter.value)
            .then(
          (value) {
            if (value != null && value is FilterProvidersModel) {
              print(value.toJson());
              context.read<ServiceProvidersCubit>().updateFilter(value);
            }
          },
        );
      },
      child: Row(
        children: [
          Text(
            AppStrings.filter.tr(),
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(fontWeight: FontWeight.w400, fontSize: 20.sp),
          ),
          2.width,
          const Icon(
            Icons.arrow_drop_down,
            color: AppColors.dropDownIconColor,
          ),
          4.width,
          SvgImageWidget(
            image: AppIcons.filter,
            width: 20.w,
            height: 20.h,
          )
        ],
      ),
    );
  }
}
