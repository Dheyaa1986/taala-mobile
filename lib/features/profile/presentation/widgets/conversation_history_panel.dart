import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_card_shell.dart';

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
    final tokens = TaalaTokens.of(context);

    return SettingsCardShell(
      padding: REdgeInsets.all(16),
      borderRadius: tokens.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.conversationHistory.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
          ),
          6.height,
          Text(
            AppStrings.conversationHistorySubtitle.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                  height: 1.4,
                ),
          ),
          12.height,
          if (_entries.isEmpty)
            _EmptyConversationHistory(tokens: tokens)
          else
            ..._entries.map(
              (entry) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10.h),
                padding: REdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(entry),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: tokens.error,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    if (entry.theirLines.isNotEmpty) ...[
                      8.height,
                      Text(
                        AppStrings.incomingReplies.tr(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.primary,
                            ),
                      ),
                      4.height,
                      Text(
                        entry.theirLines.map((line) => line.text).join('\n'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: tokens.textPrimary,
                            ),
                      ),
                    ],
                    if (entry.myLines.isNotEmpty) ...[
                      8.height,
                      Text(
                        AppStrings.myMessages.tr(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.textSecondary,
                            ),
                      ),
                      4.height,
                      Text(
                        entry.myLines.map((line) => line.text).join('\n'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: tokens.textPrimary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyConversationHistory extends StatelessWidget {
  const _EmptyConversationHistory({required this.tokens});

  final TaalaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: tokens.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: tokens.primary,
              size: 28.r,
            ),
          ),
          12.height,
          Text(
            AppStrings.noConversationHistory.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
          ),
          6.height,
          Text(
            AppStrings.noConversationHistoryHint.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
