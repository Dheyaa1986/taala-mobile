import 'package:easy_localization/easy_localization.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/error/exceptions.dart';

class ApiResponseHelper {
  static Map<String, dynamic> unwrap(dynamic json) {
    if (json is Map<String, dynamic>) {
      final payload = json['response'] ?? json;
      return asMap(payload);
    }
    if (json is Map) {
      final payload = json['response'] ?? json;
      return asMap(payload);
    }
    throw CustomException(AppStrings.genericError.tr());
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, entry) => MapEntry(key.toString(), entry),
      );
    }
    throw CustomException(AppStrings.genericError.tr());
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
