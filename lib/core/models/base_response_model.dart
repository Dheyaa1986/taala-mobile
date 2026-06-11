class BaseResponseModel {
  BaseResponseModel({
    required this.code,
    required this.message,
    this.requiresApproval = false,
  });

  final int? code;
  final String? message;
  final bool requiresApproval;

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'];
    var message = json['message']?.toString();
    var requiresApproval = false;

    if (response is Map<String, dynamic>) {
      if (response.containsKey('message')) {
        message = response['message']?.toString();
      }
      requiresApproval = response['requiresApproval'] == true;
    } else if (json.containsKey('additionalProp1') &&
        json['additionalProp1'] is Map<String, dynamic> &&
        (json['additionalProp1'] as Map<String, dynamic>)
            .containsKey('message')) {
      message = json['additionalProp1']['message']?.toString();
    } else if (response != null) {
      message = response.toString();
    }

    return BaseResponseModel(
      code: json['code'] as int?,
      message: message,
      requiresApproval: requiresApproval,
    );
  }

  factory BaseResponseModel.fromEJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      code: json['code'] as int?,
      message: json['error']?['message']?.toString(),
    );
  }
}
