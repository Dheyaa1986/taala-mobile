import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';


class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.richText = false,
    this.richTextTitle = '',
  });
  final String title;
  final String subTitle;
  final bool richText;
  final String richTextTitle ;
  @override
  Widget build(BuildContext context) {
    return    Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             SizedBox(width: 50.w),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),

            LangPopup(),
          ],
        ),
        Padding(
          padding:  REdgeInsets.symmetric(
              horizontal: 40
          ),
          child:richText ?
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: subTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextSpan(
                  text: richTextTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ):
          Text(

            subTitle,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
