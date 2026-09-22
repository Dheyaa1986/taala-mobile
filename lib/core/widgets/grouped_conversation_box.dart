import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

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

    final tokens = TaalaTokens.of(context);

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: REdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? tokens.primarySoft : tokens.surfaceMuted,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isMine
                ? tokens.primary.withValues(alpha: 0.35)
                : tokens.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.primary,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: tokens.textPrimary,
                          ),
                    ),
                    if (line.time != null) ...[
                      4.height,
                      Text(
                        DateFormat.yMMMd().add_jm().format(line.time!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: tokens.textSecondary,
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
