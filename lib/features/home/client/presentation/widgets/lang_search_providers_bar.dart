import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/notification_icon_button.dart';
import 'package:taal/core/widgets/buttons/profile_icon_button.dart';
import 'package:taal/core/widgets/fields/custom_search_field.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';

import '../../../../../core/app_config/app_strings.dart';

class LangSearchProvidersWidget extends StatelessWidget {
  const LangSearchProvidersWidget(
      {super.key, required this.controller, this.onChanged});
  final TextEditingController controller;
  final Function(String?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(

        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const ProfileIconButton(),
              Expanded(
                child: CustomSearchField(

                  hint: AppStrings.search.tr(),
                  controller: controller,
                  onChanged: onChanged,
                ),
              ),
              8.width,
              const NotificationIconButton(),
              const LangPopup(),
            ],
          )
        ],
      ),
    );
  }
}
