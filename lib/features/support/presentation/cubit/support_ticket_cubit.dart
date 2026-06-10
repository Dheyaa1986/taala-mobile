import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/features/support/data/models/support_ticket_model.dart';
import 'package:taal/features/support/data/repository/support_ticket_repository.dart';

part 'support_ticket_state.dart';

class SupportTicketCubit extends Cubit<SupportTicketState> {
  SupportTicketCubit(this._repository) : super(SupportTicketInitial());

  final SupportTicketRepository _repository;

  Future<void> loadTickets({bool reset = false}) async {
    if (reset || state is! SupportTicketsLoaded) {
      emit(SupportTicketsLoading());
    }

    final currentPage = reset || state is! SupportTicketsLoaded
        ? 1
        : (state as SupportTicketsLoaded).page + 1;

    final result = await _repository.getMyTickets(page: currentPage);
    result.fold(
      (error) => emit(SupportTicketsError(error.message)),
      (page) {
        final previous = (!reset && state is SupportTicketsLoaded)
            ? (state as SupportTicketsLoaded).items
            : <SupportTicketModel>[];
        emit(SupportTicketsLoaded(
          items: reset ? page.items : [...previous, ...page.items],
          page: currentPage,
          reachedMax: currentPage >= page.totalPages,
        ));
      },
    );
  }

  Future<void> loadTicketDetail(String id) async {
    emit(SupportTicketDetailLoading());
    final result = await _repository.getTicketById(id);
    result.fold(
      (error) => emit(SupportTicketDetailError(error.message)),
      (ticket) => emit(SupportTicketDetailLoaded(ticket)),
    );
  }

  Future<bool> sendReply(String ticketId, String body) async {
    final result = await _repository.sendMessage(
      ticketId: ticketId,
      body: body,
    );
    return result.fold(
      (error) {
        emit(SupportTicketDetailError(error.message));
        return false;
      },
      (ticket) {
        emit(SupportTicketDetailLoaded(ticket));
        return true;
      },
    );
  }
}
