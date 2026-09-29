import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';
import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/usage_guides/data/models/usage_guide_model.dart';

abstract class UsageGuidesRepository {
  Future<Either<CustomException, UsageGuidesResponse>> fetchGuides({
    String? audience,
  });

  Future<String> resolveAudience();
}

class UsageGuidesRepositoryImpl extends Repository
    implements UsageGuidesRepository {
  @override
  Future<String> resolveAudience() async {
    if (await GuestSessionHelper.isGuestBrowsing()) {
      return 'guest';
    }
    if (await AuthSessionHelper.isProviderSession()) {
      return 'provider';
    }
    return 'client';
  }

  @override
  Future<Either<CustomException, UsageGuidesResponse>> fetchGuides({
    String? audience,
  }) async {
    final resolved = audience ?? await resolveAudience();
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.usageGuides(resolved),
          method: RequestMethod.get,
          requestWithOutToken: true,
        ),
      );
      return UsageGuidesResponse.fromJson(ApiResponseHelper.unwrap(json));
    });
  }
}
