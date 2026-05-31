import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/models/theme_model.dart';

abstract class ThemeRepository {
  Future<Either<CustomException, ThemeModel>> getActiveTheme();
  Future<Either<CustomException, List<ThemeModel>>> getAllThemes();
}
