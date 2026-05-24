import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/fields/custom_drop_down_field.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';

import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../core/app_config/app_colors.dart';

Future showSettingsCustomSheet(BuildContext context, Widget child,String title,String confirmText,Function()? onConfirm) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SettingsCustomSheet(
      onConfirm:  onConfirm,
    title:  title,
    confirmText:  confirmText,
      widget: child,
    ),
  );
}

class SettingsCustomSheet extends StatefulWidget {
 const SettingsCustomSheet({super.key, this.widget = const SizedBox(), required this.title, required this.onConfirm,required this.confirmText});
 final Widget widget;
  final String title;
  final String confirmText;
  final Function()? onConfirm;
  @override
  State<SettingsCustomSheet> createState() => _SettingsCustomSheetState();
}

class _SettingsCustomSheetState extends State<SettingsCustomSheet> {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),),

          Divider(
            color: AppColors.lightGreyDividerColor,
            height: 36.h,
          ),
          widget.widget,
          16.height,
         Row(
           children: [
             Expanded(child:  CustomButton.filled(

               text: widget.confirmText.tr(),
               onTap: () => context.pop(),
             ),),
             8.width,
             Expanded(child:  CustomButton.outlined(
               borderColor:  AppColors.primaryColor,
               textColor:  AppColors.primaryColor,
               text: AppStrings.cancel.tr(),
               onTap: () => context.pop(),
             ),),
           ],
         )
        ],
      ),
    );
  }
}

class SettingsSheetHeader extends StatelessWidget {
  const SettingsSheetHeader({super.key, required this.title,});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
          ),),

        Divider(
          color: AppColors.lightGreyDividerColor,
          height: 36.h,
        ),
      ],
    );
  }
}
