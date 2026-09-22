import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/support/data/models/support_ticket_model.dart';

class SupportTicketCard extends StatelessWidget {
  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onDelete,
  });

  final SupportTicketModel ticket;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  bool get _isHighlighted =>
      ticket.status == 'new' || ticket.status == 'in_progress';

  String _statusLabel(String status) {
    switch (status) {
      case 'new':
        return AppStrings.ticketStatusNew.tr();
      case 'in_progress':
        return AppStrings.ticketStatusInProgress.tr();
      case 'resolved':
        return AppStrings.ticketStatusResolved.tr();
      case 'closed':
        return AppStrings.ticketStatusClosed.tr();
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return YellowHighlightCard(
      isHighlighted: _isHighlighted,
      onTap: onTap,
      onDelete: onDelete,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                ),
                6.height,
                Text(
                  '${ticket.type == 'complaint' ? AppStrings.complaint.tr() : AppStrings.request.tr()} • ${_statusLabel(ticket.status)}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: tokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == ui.TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: tokens.primary,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
