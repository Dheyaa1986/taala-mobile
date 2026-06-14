import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app_config/app_strings.dart';
import '../di/service_locator.dart';
import '../error/exceptions.dart';
import '../network/dio_service.dart';

abstract class Repository {
  DioService dioService = getIt<DioService>();
  Future<Either<CustomException, ReturnType>> exceptionHandler<ReturnType>(
      Future<ReturnType> Function() function) async {
    try {
      return Right(await function());
    } on CustomException catch (e) {
      debugPrint(e.toString());

      return Left(
        e,
      );
    } on FormatException catch (e) {
      debugPrint(e.toString());
      return Left(CustomException(AppStrings.genericError.tr()));
    } catch (e, trace) {
      debugPrint(e.toString());
      debugPrint(trace.toString());
      return Left(
        CustomException(AppStrings.genericError.tr()),
      );
    }
  }
}
