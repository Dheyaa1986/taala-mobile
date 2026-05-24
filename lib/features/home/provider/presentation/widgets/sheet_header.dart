import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/back_button.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key,required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomBackButton(),
        16.width,
         Text(title.tr(),style: Theme.of(context).textTheme.labelLarge!.copyWith(
           fontSize: 20.sp,
           fontWeight: FontWeight.w400,
         ),)
      ],
    );
  }
}
