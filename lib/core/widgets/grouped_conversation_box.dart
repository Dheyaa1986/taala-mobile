import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';

class GroupedConversationBox extends StatelessWidget {
  const GroupedConversationBox({
    super.key,
    required this.title,
    required this.lines,
    required this.isMine,
  });

  final String title;
  final List<ConversationLine> lines;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment:
          isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: REdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : AppColors.textFieldFillColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isMine
                ? AppColors.primaryColor.withValues(alpha: 0.35)
                : AppColors.brandBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
            10.height,
            ...lines.map(
              (line) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.45,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    if (line.time != null) ...[
                      4.height,
                      Text(
                        DateFormat.yMMMd().add_jm().format(line.time!),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.commentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
