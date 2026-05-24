
import '../../../../../core/models/base_response_model.dart';

class RegisterResponseModel {
  final String name;
  BaseResponseModel baseResponseModel;
  RegisterResponseModel({
    required this.name,
    required this.baseResponseModel,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
          name: '', baseResponseModel: BaseResponseModel.fromJson(json));
}
