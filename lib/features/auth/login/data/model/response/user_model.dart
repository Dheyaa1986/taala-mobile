import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/base_response_model.dart';

class LoginResponseModel extends BaseResponseModel {
  final String token;
  final String refreshToken;
  LoginResponseModel({
    required super.code,
    required super.message,
    required this.token,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson({required Map<String, dynamic> json}) {
    final payload = json['response'];
    final nested = payload is Map<String, dynamic>
        ? (payload['response'] is Map<String, dynamic>
            ? payload['response'] as Map<String, dynamic>
            : payload)
        : json;
    final map = nested;
    final token = map['token']?.toString() ??
        json['token']?.toString() ??
        '';
    final refreshToken = map['refreshToken']?.toString() ??
        json['refreshToken']?.toString() ??
        '';
    if (token.isEmpty || refreshToken.isEmpty) {
      throw CustomException(AppStrings.genericError.tr());
    }
    return LoginResponseModel(
      code: json['code'] is int ? json['code'] as int : int.tryParse('${json['code']}'),
      message: json['message']?.toString() ?? '',
      token: token,
      refreshToken: refreshToken,
    );
  }
}

class UserModel extends Equatable {
  final int roleId, iat, exp;
  final String name, email, profileImage, id;

  const UserModel(
      {required this.id,
      required this.roleId,
      required this.name,
      required this.email,
      required this.iat,
      required this.exp,

      required this.profileImage});

  @override
  List<Object?> get props => [
        id,
        roleId,
        name,
      ];

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        iat: json['iat'] ?? 0,
        exp: json['exp'] ?? 0,
        id: json['id'] ?? '',
        roleId: json['role'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        profileImage: json['image'] ?? '',

      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": roleId,
        "iat": iat,
        "exp": exp,
        "image": profileImage,
      };
}
