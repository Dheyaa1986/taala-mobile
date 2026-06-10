part of 'support_ticket_cubit.dart';

sealed class SupportTicketState {}

final class SupportTicketInitial extends SupportTicketState {}

final class SupportTicketsLoading extends SupportTicketState {}

final class SupportTicketsLoaded extends SupportTicketState {
  SupportTicketsLoaded({
    required this.items,
    required this.page,
    required this.reachedMax,
  });

  final List<SupportTicketModel> items;
  final int page;
  final bool reachedMax;
}

final class SupportTicketsError extends SupportTicketState {
  SupportTicketsError(this.message);
  final String message;
}

final class SupportTicketDetailLoading extends SupportTicketState {}

final class SupportTicketDetailLoaded extends SupportTicketState {
  SupportTicketDetailLoaded(this.ticket);
  final SupportTicketModel ticket;
}

final class SupportTicketDetailError extends SupportTicketState {
  SupportTicketDetailError(this.message);
  final String message;
}
