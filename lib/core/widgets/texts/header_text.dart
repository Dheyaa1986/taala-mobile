import 'package:flutter/material.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/font_styles.dart';

class ScreenTitleWidget extends StatelessWidget {
  const ScreenTitleWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.titleStyle,
    this.subTitleStyle,
    this.hasSubtitle,
    this.centerTitle,
    this.centerSubtitle = true,
  });
  final String title;
  final String? subTitle;
  final TextStyle? titleStyle, subTitleStyle;
  final bool? hasSubtitle;
  final bool? centerTitle;
  final bool? centerSubtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        24.height,
        centerTitle == true
            ? Center(
                child: Text(
                  title,
                  style: titleStyle ?? FontStyles.textStyle24,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle ?? FontStyles.textStyle24,
                    ),
                  ),
                ],
              ),
        if (hasSubtitle == true && subTitle != null)
          Column(
crossAxisAlignment: centerSubtitle == true ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
            children: [
              8.height,
              Text(
                subTitle!,
                textAlign: TextAlign.start,
                style: subTitleStyle ?? FontStyles.textStyle14,
              ),
            ],
          ),
      ],
    );
  }
}
