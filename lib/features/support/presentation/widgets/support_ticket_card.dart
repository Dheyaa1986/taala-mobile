import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/font_styles.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
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
                  style: TextStyle(
                    fontFamily: FontStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightMainText,
                  ),
                ),
                6.height,
                Text(
                  '${ticket.type == 'complaint' ? AppStrings.complaint.tr() : AppStrings.request.tr()} • ${_statusLabel(ticket.status)}',
                  style: TextStyle(
                    fontFamily: FontStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.commentColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
