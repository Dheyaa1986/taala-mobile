import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';

class ConversationHistoryPanel extends StatefulWidget {
  const ConversationHistoryPanel({super.key});

  @override
  State<ConversationHistoryPanel> createState() =>
      _ConversationHistoryPanelState();
}

class _ConversationHistoryPanelState extends State<ConversationHistoryPanel> {
  List<ConversationHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _entries = ConversationHistoryHelper.getAll());
  }

  Future<void> _confirmDelete(ConversationHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteConversationHistory.tr()),
        content: Text(AppStrings.deleteConversationHistorySubtitle.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ConversationHistoryHelper.delete(entry.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: AppColors.brandBorder),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: REdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.conversationHistory.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.lightMainText,
              ),
            ),
            6.height,
            Text(
              AppStrings.conversationHistorySubtitle.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.commentColor,
                height: 1.4,
              ),
            ),
            12.height,
            if (_entries.isEmpty)
              Text(
                AppStrings.noConversationHistory.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.commentColor,
                ),
              )
            else
              ..._entries.map(
                (entry) => Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: REdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFillColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.brandBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _confirmDelete(entry),
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.redColor,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                      if (entry.theirLines.isNotEmpty) ...[
                        8.height,
                        Text(
                          AppStrings.incomingReplies.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        4.height,
                        Text(
                          entry.theirLines.map((line) => line.text).join('\n'),
                          style: TextStyle(fontSize: 13.sp, height: 1.4),
                        ),
                      ],
                      if (entry.myLines.isNotEmpty) ...[
                        8.height,
                        Text(
                          AppStrings.myMessages.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.commentColor,
                          ),
                        ),
                        4.height,
                        Text(
                          entry.myLines.map((line) => line.text).join('\n'),
                          style: TextStyle(fontSize: 13.sp, height: 1.4),
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
