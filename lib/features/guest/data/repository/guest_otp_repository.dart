import 'package:dartz/dartz.dart';
import 'package:taal/core/helpers/phone_helper.dart';
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
      final raw = await dioService.callApi(
        NetworkRequest(
          AppUrls.guestSendOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {'phone': PhoneFormatterHelper.normalizeForApi(phone.trim())},
        ),
      );

      return GuestOtpSendResult(
        debugOtp: _extractPayload(raw)['debugOtp']?.toString(),
      );
    });
  }

  Future<Either<CustomException, GuestOtpSendResult>> sendRegistrationOtp(
    String phone,
  ) {
    return exceptionHandler(() async {
      final raw = await dioService.callApi(
        NetworkRequest(
          AppUrls.clientSendOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {'phone': PhoneFormatterHelper.normalizeForApi(phone.trim())},
        ),
      );

      return GuestOtpSendResult(
        debugOtp: _extractPayload(raw)['debugOtp']?.toString(),
      );
    });
  }

  Map<String, dynamic> _extractPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['response'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      return raw;
    }
    if (raw is Map) {
      return _extractPayload(Map<String, dynamic>.from(raw));
    }
    throw BadRequestException('استجابة غير متوقعة من الخادم');
  }
}
