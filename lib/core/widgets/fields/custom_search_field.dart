import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../svg_image/svg_image_widget.dart';
import 'custom_text_field.dart';


class CustomSearchField extends StatelessWidget {
  const CustomSearchField(
      {super.key, required this.controller, this.onChanged, this.onTap,this.hint});
  final TextEditingController controller;
  final Function(String?)? onChanged;
  final Function()? onTap;
  final String? hint;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(

      onTap: onTap,
      prefix: const Padding(
        padding: EdgeInsets.all(12),
        child: SvgImageWidget(
          image: AppIcons.search,
        ),
      ),
      hint:hint?? AppStrings.search.tr(),
      onChanged: onChanged,
      controller: controller,
    );
  }
}
