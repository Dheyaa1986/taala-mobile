import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/network/network_request.dart';
import '../model/request/login_request_options.dart';
import '../model/response/user_model.dart';
import 'login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<Either<CustomException, LoginResponseModel>> login(
      {required LoginOptions model}) async {
    final result = await exceptionHandler(
      () async {
        LoginResponseModel user = await dioService.callApi(
          NetworkRequest(AppUrls.login,
              method: RequestMethod.post,
              body: model.toJson(),
              requestWithOutToken: true),
          mapper: (json) => LoginResponseModel.fromJson(
            json: json,
          ),
        );
        await SecureLocalStorage.write(PrefsKeys.token, user.token);
        await SecureLocalStorage.write(
          PrefsKeys.password,
          model.password,
        );
        await SecureLocalStorage.write(
          PrefsKeys.mailOrPhone,
          model.email,
        );
        // await singInWithFirebase(
        //     UserModel.fromJson(JwtDecoder.decode(user.token)));

        await SecureLocalStorage.write(
          PrefsKeys.user,
          jsonEncode(
            JwtDecoder.decode(user.token),
          ),
        );
        return user;
      },
    );

    return result;
  }

/*  singInWithFirebase(UserModel user) async {
    try {

      await firestore
          .collection('Users')
          .doc(user.id.toString())
          .set(user.toFirestoreJson());

    } catch (e) {
      log(e.toString());
    }
  }*/


}
