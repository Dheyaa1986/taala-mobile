import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<SupportTicketCubit>().loadTicketDetail(widget.ticketId);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(title: AppStrings.supportChat.tr()),
      body: BlocBuilder<SupportTicketCubit, SupportTicketState>(
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

          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: REdgeInsets.all(16),
                  children: [
                    _MessageBubble(
                      sender: AppStrings.you.tr(),
                      body: ticket.description,
                      isMine: true,
                      time: ticket.createdAt,
                    ),
                    ...ticket.messages.map(
                      (msg) => _MessageBubble(
                        sender: msg.isFromAdmin
                            ? AppStrings.admin.tr()
                            : msg.senderName,
                        body: msg.body,
                        isMine: !msg.isFromAdmin,
                        time: msg.createdAt,
                      ),
                    ),
                  ],
                ),
              ),
              if (!ticket.isClosed)
                Padding(
                  padding: REdgeInsets.fromLTRB(16, 8, 16, 16),
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
                )
              else
                Padding(
                  padding: REdgeInsets.all(16),
                  child: Text(
                    AppStrings.ticketClosed.tr(),
                    style: TextStyle(color: AppColors.greyText),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.sender,
    required this.body,
    required this.isMine,
    this.time,
  });

  final String sender;
  final String body;
  final bool isMine;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: REdgeInsets.only(bottom: 12),
        padding: REdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.lightGreyDividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.greyText,
              ),
            ),
            6.height,
            Text(body),
            if (time != null) ...[
              6.height,
              Text(
                DateFormat.yMMMd().add_jm().format(time!),
                style: TextStyle(fontSize: 10.sp, color: AppColors.greyText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
