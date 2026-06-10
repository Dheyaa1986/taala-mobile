import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/models/base_response_model.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/support/data/models/support_ticket_model.dart';

class SupportTicketRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> submitTicket({
    required String title,
    required String description,
    required String type,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.supportTickets,
          method: RequestMethod.post,
          body: {
            'title': title,
            'description': description,
            'type': type,
          },
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, SupportTicketsPageModel>> getMyTickets({
    int page = 1,
    int limit = 20,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.supportTicketsMe,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'limit': limit},
        ),
        mapper: (json) => SupportTicketsPageModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, SupportTicketModel>> getTicketById(
      String id) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.supportTicketById(id),
          method: RequestMethod.get,
        ),
        mapper: (json) {
          final response = json['response'] as Map<String, dynamic>? ?? json;
          return SupportTicketModel.fromJson(response);
        },
      );
    });
  }

  Future<Either<CustomException, SupportTicketModel>> sendMessage({
    required String ticketId,
    required String body,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.supportTicketMessages(ticketId),
          method: RequestMethod.post,
          body: {'body': body},
        ),
        mapper: (json) {
          final response = json['response'] as Map<String, dynamic>? ?? json;
          return SupportTicketModel.fromJson(response);
        },
      );
    });
  }
}
