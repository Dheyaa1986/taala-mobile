import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';

class ProvidersRepositoryImpl extends Repository implements ProviderRepository {
  @override
  Future<Either<CustomException, List<ServiceProviderModel>>> getProviders({
    required String clientId,
    required ProvidersPaginationOptions options,
  }) async {
    return exceptionHandler(() async {
      final filter = options.filter;
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.clientHome(clientId),
          method: RequestMethod.get,
          queryParameters: {
            'page': options.page,
            'limit': options.limit,
            if (options.search != null && options.search!.isNotEmpty)
              'search': options.search,
            if (filter?.serviceTypeId != null)
              'serviceTypeId': filter!.serviceTypeId,
            if (filter?.cityId != null) 'cityId': filter!.cityId,
            if (filter?.governanceId != null)
              'governorateId': filter!.governanceId,
            if (filter?.active != null) 'providerStatus': filter!.active,
          },
        ),
      );

      final response = json['response'];
      final data = response is Map<String, dynamic>
          ? response['data'] as List<dynamic>? ?? []
          : response is List
              ? response
              : [];

      return data
          .map((e) =>
              ServiceProviderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
