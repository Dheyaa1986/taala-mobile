import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../../../../../core/repository/repository.dart';

class ClientSettingsRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> changePassword({
    required String oldPassword,
    required String password,
    required String confirmPassword,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.changePassword,
          method: RequestMethod.post,
          body: {
            'oldPassword': oldPassword,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }
}
