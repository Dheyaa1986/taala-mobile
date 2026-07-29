import 'package:dartz/dartz.dart';


import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/request/login_request_options.dart';
import '../model/response/user_model.dart';

abstract class LoginRepository  extends Repository {
  Future<Either<CustomException, LoginResponseModel>> login({
    required LoginOptions model,
    bool isProvider = false,
  });

  Future<Either<CustomException, String?>> sendClientOtp(String phone);

  Future<Either<CustomException, LoginResponseModel>> verifyClientOtp({
    required String phone,
    required String otp,
  });
}
