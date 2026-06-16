import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/alerts/app_alert_sound_service.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/conversation_history_helper.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/grouped_conversation_box.dart';
import 'package:taal/core/widgets/layout/bottom_safe_area.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/support/data/models/support_ticket_model.dart';
import 'package:taal/features/support/presentation/cubit/support_ticket_cubit.dart';

class SupportTicketDetailScreen extends StatefulWidget {
  const SupportTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _refreshTimer;
  int _knownAdminMessages = 0;

  @override
  void initState() {
    super.initState();
    context.read<SupportTicketCubit>().loadTicketDetail(widget.ticketId);
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<SupportTicketCubit>().loadTicketDetail(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final success = await context.read<SupportTicketCubit>().sendReply(
          widget.ticketId,
          text,
        );
    if (success && mounted) {
      _replyController.clear();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _handleTicketUpdate(SupportTicketModel ticket) {
    final adminCount =
        ticket.messages.where((message) => message.isFromAdmin).length;
    if (_knownAdminMessages > 0 && adminCount > _knownAdminMessages) {
      getIt<AppAlertSoundService>().play();
    }
    _knownAdminMessages = adminCount;

    final myLines = <ConversationLine>[
      ConversationLine(text: ticket.description, time: ticket.createdAt),
      ...ticket.messages
          .where((message) => !message.isFromAdmin)
          .map(
            (message) => ConversationLine(
              text: message.body,
              time: message.createdAt,
            ),
          ),
    ];
    final theirLines = ticket.messages
        .where((message) => message.isFromAdmin)
        .map(
          (message) => ConversationLine(
            text: message.body,
            time: message.createdAt,
          ),
        )
        .toList();

    ConversationHistoryHelper.save(
      ConversationHistoryEntry(
        id: 'support_${ticket.id}',
        type: 'support',
        title: ticket.title,
        myLines: myLines,
        theirLines: theirLines,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          getIt<NotificationCubit>().refreshInbox(reloadList: true);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.backAppBar(title: AppStrings.supportChat.tr()),
        body: BlocConsumer<SupportTicketCubit, SupportTicketState>(
          listener: (context, state) {
            if (state is SupportTicketDetailLoaded) {
              _handleTicketUpdate(state.ticket);
            }
          },
          builder: (context, state) {
            if (state is SupportTicketDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SupportTicketDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is! SupportTicketDetailLoaded) {
              return const SizedBox.shrink();
            }

            final ticket = state.ticket;

            final myLines = <ConversationLine>[
              ConversationLine(text: ticket.description, time: ticket.createdAt),
              ...ticket.messages
                  .where((message) => !message.isFromAdmin)
                  .map(
                    (message) => ConversationLine(
                      text: message.body,
                      time: message.createdAt,
                    ),
                  ),
            ];
            final theirLines = ticket.messages
                .where((message) => message.isFromAdmin)
                .map(
                  (message) => ConversationLine(
                    text: message.body,
                    time: message.createdAt,
                  ),
                )
                .toList();

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: REdgeInsets.all(16),
                    children: [
                      GroupedConversationBox(
                        title: AppStrings.supportTeam.tr(),
                        lines: theirLines,
                        isMine: false,
                      ),
                      GroupedConversationBox(
                        title: AppStrings.you.tr(),
                        lines: myLines,
                        isMine: true,
                      ),
                    ],
                  ),
                ),
                if (!ticket.isClosed)
                  BottomSafeArea(
                    includeKeyboard: true,
                    child: Padding(
                      padding: REdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                      children: [
                        CustomTextField(
                          controller: _replyController,
                          hint: AppStrings.typeReply.tr(),
                          maxLines: 3,
                        ),
                        12.height,
                        CustomButton.filled(
                          text: AppStrings.sendReply.tr(),
                          onTap: _sendReply,
                        ),
                      ],
                    ),
                    ),
                  )
                else
                  BottomSafeArea(
                    child: Padding(
                      padding: REdgeInsets.all(16),
                      child: Text(
                      AppStrings.ticketClosed.tr(),
                      style: TextStyle(color: AppColors.greyText),
                    ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
