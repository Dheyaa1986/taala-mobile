import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';

class GuestOtpSendResult {
  const GuestOtpSendResult({this.debugOtp});

  final String? debugOtp;
}

class GuestOtpRepository extends Repository {
  Future<Either<CustomException, GuestOtpSendResult>> sendOtp(String phone) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.guestSendOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {'phone': phone.trim()},
        ),
      );
      final response = json['response'] as Map<String, dynamic>? ?? json;
      return GuestOtpSendResult(
        debugOtp: response['debugOtp']?.toString(),
      );
    });
  }
}
