part of 'support_ticket_cubit.dart';

abstract class SupportTicketState {}

class SupportTicketInitial extends SupportTicketState {}

class SupportTicketsLoading extends SupportTicketState {}

class SupportTicketsLoaded extends SupportTicketState {
  final List<SupportTicketModel> items;
  final int page;
  final bool reachedMax;

  SupportTicketsLoaded({
    required this.items,
    required this.page,
    required this.reachedMax,
  });
}

class SupportTicketsError extends SupportTicketState {
  final String message;

  SupportTicketsError(this.message);
}
