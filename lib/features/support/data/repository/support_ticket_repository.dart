import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/models/base_response_model.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';

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
}
