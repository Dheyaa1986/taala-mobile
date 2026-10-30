import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:taal/core/network/extensions.dart';
import 'package:taal/core/provider_offering/provider_service_offering_model.dart';
import 'package:taal/features/auth/register/utils/provider_registration_documents.dart';

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
  final ProviderRegistrationDocumentFiles? providerDocuments;
  final List<ProviderServiceOfferingInput>? serviceOfferings;

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
    this.providerDocuments,
    this.serviceOfferings,
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

    if (serviceOfferings != null && serviceOfferings!.isNotEmpty) {
      map['serviceOfferings'] = jsonEncode(
        serviceOfferings!.map((item) => item.toRegistrationJson()).toList(),
      );
    }

    final otpCode = otp?.trim();
    if (otpCode != null && otpCode.isNotEmpty) {
      map['otp'] = otpCode;
    }

    final docs = providerDocuments;
    if (docs != null) {
      await _appendDocument(map, 'nationalIdFront', docs.nationalIdFront);
      await _appendDocument(map, 'nationalIdBack', docs.nationalIdBack);
      await _appendDocument(map, 'vehicleRegFront', docs.vehicleRegFront);
      await _appendDocument(map, 'vehicleRegBack', docs.vehicleRegBack);
      await _appendDocument(map, 'residenceCardFront', docs.residenceCardFront);
      await _appendDocument(map, 'residenceCardBack', docs.residenceCardBack);
    }

    return FormData.fromMap(map);
  }

  Future<void> _appendDocument(
    Map<String, dynamic> map,
    String field,
    File? file,
  ) async {
    if (file == null) return;
    map[field] = await fileToMultipartFile(file);
  }
}
