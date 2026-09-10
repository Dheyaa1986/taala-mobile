import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/subscriptions/data/models/provider_subscription_model.dart';

class SubscriptionRepository extends Repository {
  Future<Either<CustomException, ProviderSubscriptionModel>> getMySubscription() {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(AppUrls.subscriptionsMe),
        mapper: (json) => ProviderSubscriptionModel.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    });
  }

  Future<Either<CustomException, List<SubscriptionPlanModel>>> getPlans() {
    return exceptionHandler(() async {
      final list = await dioService.callApi(
        NetworkRequest(
          AppUrls.subscriptionsPlans,
          requestWithOutToken: true,
        ),
        mapper: (json) {
          if (json is List) {
            return json
                .map(
                  (item) => SubscriptionPlanModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
          return <SubscriptionPlanModel>[];
        },
      );
      return list;
    });
  }
}
