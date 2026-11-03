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
    var requiresApproval = json['requiresApproval'] == true;
    Map<String, dynamic>? responseMap;
    if (response is Map<String, dynamic>) {
      responseMap = response;
    } else if (response is Map) {
      responseMap = response.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (responseMap != null) {
      if (responseMap.containsKey('message')) {
        message = responseMap['message']?.toString();
      }
      requiresApproval =
          requiresApproval || responseMap['requiresApproval'] == true;
    } else if (json.containsKey('additionalProp1') &&
        json['additionalProp1'] is Map &&
        (json['additionalProp1'] as Map).containsKey('message')) {
      message = json['additionalProp1']['message']?.toString();
    } else if (response != null) {
      message = response.toString();
    }

    return BaseResponseModel(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code'] ?? ''}'),
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
