import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../../../../core/app_config/app_strings.dart';

class ViewProfileButton extends StatelessWidget {
  const ViewProfileButton({super.key, this.profileId});
 final int? profileId;
  @override
  Widget build(BuildContext context) {
    return   GestureDetector(
      onTap: () {
        context.pushNamed(Routes.menu, extra: profileId);
      },
      child: Row(children: [
        Text(
          AppStrings.viewProfile.tr(),
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        2.width,
      ]),
    );
  }
}
