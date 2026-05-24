import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/widgets/buttons/custom_drop_down_icon_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

class LangPopup extends StatelessWidget {
  const LangPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomMenuButton(menuItems: [
      PopMenuModel(title: AppStrings.arabic),
      PopMenuModel(title: AppStrings.english),
      PopMenuModel(title: AppStrings.kurdish),
    ],
    onSelected: (PopMenuModel? value) {
      if (value?.title == AppStrings.arabic) {
        context.setLocale(const Locale('ar'));
      } else if (value?.title == AppStrings.english) {
        context.setLocale(const Locale('en'));
      } else if (value?.title == AppStrings.kurdish) {
        context.setLocale(const Locale('fa',));
      }
    },
    icon:  const SvgImageWidget(image: AppIcons.lang, width: 20, height: 20),
    );
  }
}
