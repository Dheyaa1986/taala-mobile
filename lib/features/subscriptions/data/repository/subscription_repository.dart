import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/subscriptions/data/models/provider_subscription_model.dart';

class SubscriptionRepository extends Repository {
  Future<Either<CustomException, ProviderSubscriptionModel>> getMySubscription() {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.subscriptionsMe,
          method: RequestMethod.get,
        ),
        mapper: (json) => ProviderSubscriptionModel.fromJson(
          ApiResponseHelper.unwrap(json),
        ),
      );
    });
  }

  Future<Either<CustomException, List<SubscriptionPlanModel>>> getPlans() {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.subscriptionsPlans,
          method: RequestMethod.get,
        ),
      );

      final response = json['response'];
      final data = response is List ? response : <dynamic>[];

      return data
          .map(
            (item) => SubscriptionPlanModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }
}
