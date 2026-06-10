import 'package:dartz/dartz.dart';

import '../../../../core/app_config/app_urls.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/theme_model.dart';
import '../../../../core/network/network_request.dart';
import '../../../../core/repository/repository.dart';
import 'theme_repository.dart';

class ThemeRepositoryImpl extends Repository implements ThemeRepository {
  @override
  Future<Either<CustomException, ThemeModel?>> getActiveTheme() async {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.themesActive,
          method: RequestMethod.get,
          requestWithOutToken: true,
        ),
      );

      final response = json['response'];
      if (response == null || response is! Map<String, dynamic>) {
        return null;
      }
      if (response['id'] == null) return null;

      return ThemeModel.fromJson(json);
    });
  }
}
