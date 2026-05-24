import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/repository/repository.dart';
import '../model/register_options.dart';

abstract class RegisterRepository extends Repository {
  Future<Either<CustomException, BaseResponseModel>> registerClient(
      {required RegisterOptions model});

}
