import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/models/theme_model.dart';
import '../../../../core/network/network_request.dart';
import '../../../../core/repository/repository.dart';
import 'theme_repository.dart';

class ThemeRepositoryImpl extends Repository implements ThemeRepository {
  @override
  Future<Either<CustomException, ThemeModel>> getActiveTheme() async {
    return await exceptionHandler(() async {
      final response = await dioService.callApi<ThemeModel>(
        NetworkRequest(
          path: '/themes/active',
          method: RequestMethod.get,
        ),
        mapper: (json) => ThemeModel.fromJson(json),
      );
      return response;
    });
  }

  @override
  Future<Either<CustomException, List<ThemeModel>>> getAllThemes() async {
    return await exceptionHandler(() async {
      final response = await dioService.callApi<List<ThemeModel>>(
        NetworkRequest(
          path: '/themes',
          method: RequestMethod.get,
        ),
        mapper: (json) {
          if (json is List) {
            return json.map((e) => ThemeModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return response;
    });
  }
}
