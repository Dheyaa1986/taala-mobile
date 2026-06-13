import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taal/core/network/extensions.dart';

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
  final String? type;
  final List<String>? serviceTypesIds;

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
    this.type,
    this.serviceTypesIds,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': username,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
      'confirmPassword': confirmPassword,
      'type': type ?? 'client',
      'profile': await fileToMultipartFile(image),
    };

    if (serviceTypesIds != null && serviceTypesIds!.isNotEmpty) {
      map['serviceTypesIds'] = jsonEncode(serviceTypesIds);
    }

    return FormData.fromMap(map);
  }
}
