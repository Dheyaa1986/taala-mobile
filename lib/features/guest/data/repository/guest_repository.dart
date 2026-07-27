import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/guest/data/models/guest_help_response_model.dart';

class GuestRepository extends Repository {
  Future<Either<CustomException, bool>> sendOtp(String phone) {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.guestSendOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {'phone': phone.trim()},
        ),
      );
      return true;
    });
  }

  Future<Either<CustomException, GuestHelpResponseModel>> requestHelp({
    required String name,
    required String phone,
    required String otp,
    required String serviceTypeId,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? providerId,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.guestHelpRequest,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {
            'name': name.trim(),
            'phone': phone.trim(),
            'otp': otp.trim(),
            'serviceTypeId': serviceTypeId,
            'clientLatitude': latitude,
            'clientLongitude': longitude,
            if (address != null && address.trim().isNotEmpty)
              'clientAddress': address.trim(),
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
            if (providerId != null && providerId.isNotEmpty)
              'providerId': providerId,
          },
        ),
        mapper: (json) => GuestHelpResponseModel.fromJson(json),
      );
    });
  }
}
