import 'dart:io';

import 'package:dio/dio.dart';

class RegisterOptions {
  final String username;
  final String phone;
  final String email;
  final String address;
  final String password;
  final String confirmPassword;
  final String country;
  final String countryImageSvg;
  final File image;
  int? role;

  RegisterOptions({
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
    required this.confirmPassword,
    required this.country,
    required this.countryImageSvg,
    required this.image,
    this.role,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'userName': username,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
      'confirmPassword': confirmPassword,
      'country': country,
      'countryImageSvg': countryImageSvg,
      'role': role ?? 1, // ✅ إذا null اجعله 1
      'image': await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last),
    });
  }
}
