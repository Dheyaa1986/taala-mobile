import 'package:dartz/dartz.dart';
import 'package:taal/core/helpers/phone_helper.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/maps/emergency/emergency_request_queue.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/guest/data/models/guest_help_response_model.dart';
import 'package:taal/features/guest/data/repository/guest_otp_repository.dart';

class GuestRepository extends Repository {
  final _otpRepository = GuestOtpRepository();
  final _queue = EmergencyRequestQueue();

  Future<Either<CustomException, GuestOtpSendResult>> sendOtp(String phone) {
    return _otpRepository.sendOtp(phone);
  }

  Future<Either<CustomException, Unit>> queueHelpOffline({
    required String name,
    required String phone,
    required String serviceTypeId,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? providerId,
  }) {
    return exceptionHandler(() async {
      final payload = EmergencyRequestPayload.create(
        name: name,
        phone: phone,
        serviceTypeId: serviceTypeId,
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        providerId: providerId,
      );
      await _queue.enqueue(payload);
      return unit;
    });
  }

  Future<Either<CustomException, GuestHelpResponseModel>> requestHelp({
    required String name,
    required String phone,
    required String serviceTypeId,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? providerId,
    String? clientRequestId,
    DateTime? queuedAt,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.guestHelpRequest,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {
            'name': name.trim(),
            'phone': PhoneFormatterHelper.normalizeForApi(phone.trim()),
            'serviceTypeId': serviceTypeId,
            'clientLatitude': latitude,
            'clientLongitude': longitude,
            if (address != null && address.trim().isNotEmpty)
              'clientAddress': address.trim(),
            if (description != null && description.trim().isNotEmpty)
              'description': description.trim(),
            if (providerId != null && providerId.isNotEmpty)
              'providerId': providerId,
            if (clientRequestId != null && clientRequestId.isNotEmpty)
              'clientRequestId': clientRequestId,
            if (queuedAt != null)
              'queuedAt': queuedAt.toUtc().toIso8601String(),
          },
        ),
        mapper: (json) => GuestHelpResponseModel.fromJson(json),
      );
    });
  }
}
