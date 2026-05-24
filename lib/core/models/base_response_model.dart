class BaseResponseModel {
  BaseResponseModel({required this.code, required this.message});

  final int? code;
  final String? message;
  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      code: json['code'],
      message: json.containsKey('additionalProp1') &&
              (json['additionalProp1'] is Map<String, dynamic> &&
                  json['additionalProp1'].containsKey('message'))
          ? json['additionalProp1']['message']
          :json['response'] is Map<String, dynamic> && (json['response'] as Map<String,dynamic>).containsKey('message')? json['response']['message']:json['response'].toString()??json['message']??'',
    );
  }
  factory BaseResponseModel.fromEJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      code: json['code'],
      message: json['error']['message'],
    );
  }
}

/*class BaseResponseModel<T> {
  final int code;
  final String? message;
  final T? response;

  BaseResponseModel({required this.code, required this.response, this.message});

  factory BaseResponseModel.fromJson(Map<String, dynamic> json,
      {T Function(Map<String, dynamic>)? fromJsonT}) {
    return BaseResponseModel(
      code: json['code'],
      message: json.containsKey('additionalProp1') &&
              (json['additionalProp1'] is Map<String, dynamic> &&
                  json['additionalProp1'].containsKey('message'))
          ? json['additionalProp1']['message']
          : "",
      response: json.containsKey('response') &&
              json['response'] is Map<String, dynamic> &&
              fromJsonT != null
          ? fromJsonT(json['response'])
          : null,
    );
  }
}*/
