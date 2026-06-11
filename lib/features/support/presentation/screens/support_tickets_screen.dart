import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/support/presentation/cubit/support_ticket_cubit.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_card.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_sheet.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportTicketCubit>().loadTickets(reset: true);
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteTicket.tr()),
        content: Text(AppStrings.deleteTicketSubtitle.tr()),
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

    if (confirmed == true && mounted) {
      await context.read<SupportTicketCubit>().deleteTicket(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.mySupportTickets.tr(),
        actions: [
          IconButton(
            onPressed: () async {
              await showSupportTicketSheet(context);
              if (context.mounted) {
                context.read<SupportTicketCubit>().loadTickets(reset: true);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<SupportTicketCubit, SupportTicketState>(
        builder: (context, state) {
          if (state is SupportTicketsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupportTicketsError) {
            return Center(child: Text(state.message));
          }
          if (state is SupportTicketsLoaded) {
            if (state.items.isEmpty) {
              return Center(child: Text(AppStrings.noSupportTickets.tr()));
            }
            return ListView.separated(
              padding: REdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (context, index) {
                final ticket = state.items[index];
                return SupportTicketCard(
                  ticket: ticket,
                  onTap: () {
                    context.pushNamed(
                      Routes.supportTicketDetail,
                      pathParameters: {'id': ticket.id},
                    );
                  },
                  onDelete: ticket.isClosed
                      ? () => _confirmDelete(ticket.id)
                      : null,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
