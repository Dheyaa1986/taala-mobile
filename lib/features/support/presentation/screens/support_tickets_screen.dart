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
                return Card(
                  child: ListTile(
                    title: Text(ticket.title),
                    subtitle: Text(
                      '${ticket.type == 'complaint' ? AppStrings.complaint.tr() : AppStrings.request.tr()} • ${_statusLabel(ticket.status)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.pushNamed(
                        Routes.supportTicketDetail,
                        pathParameters: {'id': ticket.id},
                      );
                    },
                  ),
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
