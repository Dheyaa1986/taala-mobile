import 'package:equatable/equatable.dart';

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
    return LoginResponseModel(
        code: json['code'],
        message: '',
        token: json['response']['token'],
        refreshToken: json['response']['refreshToken']);
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
  Map<String, dynamic> toFirestoreJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": roleId,
        "iat": iat,
        "exp": exp,
        "image": profileImage,
      };
}
