import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../error/errors_exceptions_handler.dart';
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
    } catch (e, trace) {
      debugPrint(e.toString());
      debugPrint(trace.toString());
      return Left(
        CustomException(
          (e is CustomException)
              ? e.message.toString()
              : "Something went wrong, please try again later.",
        ),
      );
    }
  }
}
