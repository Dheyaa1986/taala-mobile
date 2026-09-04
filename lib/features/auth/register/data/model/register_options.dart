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
  final File? image;
  final String? type;
  final List<String>? serviceTypesIds;
  final String? otp;

  RegisterOptions({
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
    required this.confirmPassword,
    required this.country,
    required this.countryImageSvg,
    this.image,
    this.type,
    this.serviceTypesIds,
    this.otp,
  });

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'type': type ?? 'client',
    };

    final trimmedPhone = phone.trim();
    if (trimmedPhone.isNotEmpty) {
      map['phone'] = trimmedPhone;
    }

    final trimmedAddress = address.trim();
    if (trimmedAddress.isNotEmpty) {
      map['address'] = trimmedAddress;
    }

    if (image != null) {
      map['profile'] = await fileToMultipartFile(image!);
    }

    if (serviceTypesIds != null && serviceTypesIds!.isNotEmpty) {
      map['serviceTypesIds'] = jsonEncode(serviceTypesIds);
    }

    final otpCode = otp?.trim();
    if (otpCode != null && otpCode.isNotEmpty) {
      map['otp'] = otpCode;
    }

    return FormData.fromMap(map);
  }
}
