/*
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';


import '../app_config/prefs_keys.dart';

class UserHelper {
  static final ValueNotifier<UserModel?> _userNotifier = ValueNotifier(null);

  static ValueNotifier<UserModel?> get userNotifier => _userNotifier;

  static void setUser(UserModel user) => _userNotifier.value = user;
*/
/*  static singInWithFirebase(UserModel user) async {
    try {
*//*
*/
/*      UserCredential userCredential = await firebase.signInWithEmailAndPassword(
        email: options.email, // Replace with actual user input
        password: options.password, // Replace with actual user input
      );*//*
*/
/*

      // Prepare user data (you can add more fields as needed)

      // Store user data in Firestore under the UID as the document ID
      await firestore
          .collection('Users')
          .doc(user.id.toString())
          .set(user.toFirestoreJson());
      log('Store user data in Firestore under the UID as the document ID');
    } catch (e) {
      log(e.toString());
    }
  }*//*


*/
/*  static void reload() async {
    if (_userNotifier.value == null) return;
    late final UserModel user;
    if (_userNotifier.value?.roleId == 2) {
      final response = await getIt<GetClientProfileUseCase>().call(null);
      response.fold((fail) {
        log(fail.message);
      }, (entity) async {
        user = UserModel(
          id: _userNotifier.value!.id,
          roleId: _userNotifier.value!.roleId,
         exp: _userNotifier.value!.exp,
          iat: _userNotifier.value!.iat,
          name: entity.name ?? '',
          email: entity.email ?? '',

          profileImage: entity.image ?? '',
        );
        setUser(user);
        await singInWithFirebase(user);
        await SecureLocalStorage.write(
          PrefsKeys.user,
          jsonEncode(
            user.toJson(),
          ),
        );
      });
      return;
    }
    final response = await getIt<FetchTrainerProfileUsecase>().call(null);
    response.fold((fail) {
      log(fail.message);
    }, (entity) async {
      user = User(
        id: _userNotifier.value!.id,
        roleId: _userNotifier.value!.roleId,
        isActive: _userNotifier.value!.isActive,
        isVerified: _userNotifier.value!.isVerified,
        name: entity.trainerName,
        email: _userNotifier.value!.email,
        isApproved: _userNotifier.value!.isApproved,
        isRejected: _userNotifier.value!.isRejected,
        isProfileCompleted: _userNotifier.value!.isProfileCompleted,
        profileStatusMessage: _userNotifier.value!.profileStatusMessage,
        token: _userNotifier.value?.token ?? '',
        profileImage: entity.profileImage,
      );
      setUser(user);
      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(
          UserModel.fromEntity(user).toJson(),
        ),
      );
      await singInWithFirebase(UserModel.fromEntity(user));
    });
  }*//*


  static void clear() => _userNotifier.value = null;
}*/
