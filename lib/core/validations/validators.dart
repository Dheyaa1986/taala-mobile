import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/helpers.dart';

import '../app_config/app_strings.dart';
import '../countries/data/model/country_model.dart';

class CustomValidators {
  static String? validateEmpty(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? AppStrings.requiredField.tr();
    }
    return null;
  }

  /// Requires at least three name parts (e.g. first, father, grandfather).
  static String? validateTripleName(String? value, {String? message}) {
    final errorText = message ?? AppStrings.tripleNameValidation.tr();

    if (value == null || value.trim().isEmpty) {
      return errorText;
    }

    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length < 3) {
      return errorText;
    }

    for (final part in parts) {
      if (part.length < 2) {
        return errorText;
      }
    }

    return null;
  }
  String? validateEgyptianID(String? id) {
    if (id == null || id.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    }

    if (id.length != 14 || int.tryParse(id) == null) {
      return AppStrings.notAValidId.tr();
    }

    final century = id[0];
    final birthDateString = id.substring(1, 7); // YYMMDD
    final governorateCode = int.tryParse(id.substring(7, 9));

    // Validate century
    if (century != '2' && century != '3') {
      return AppStrings.notAValidId.tr();
    }

    // Validate governorate code
    if (governorateCode == null || governorateCode < 1 || governorateCode > 99) {
      return AppStrings.notAValidId.tr();
    }

    // Validate date
    try {
      final yearPrefix = century == '2' ? 1900 : 2000;
      final year = yearPrefix + int.parse(birthDateString.substring(0, 2));
      final month = int.parse(birthDateString.substring(2, 4));
      final day = int.parse(birthDateString.substring(4, 6));
      final date = DateTime(year, month, day);

      // Make sure parsed values are valid
      if (date.year != year || date.month != month || date.day != day) {
        return AppStrings.notAValidId.tr();
      }
    } catch (_) {
      return AppStrings.notAValidId.tr();
    }

    return null; // valid ID
  }



  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (password.length < 8) {
      return AppStrings.passwordLengthValidation.tr();
    } else {
      return null;
    }
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (confirmPassword == password) {
      return null;
    } else {
      return AppStrings.passwordMatchValidation.tr();
    }
  }

  static String? validateEmail(String? value, {String? message}) {
    if (value?.trim().isEmpty ?? true) {
      return message ?? AppStrings.requiredField.tr();
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.["
            r"a-zA-Z]+")
        .hasMatch(value!)) {
      return message ?? AppStrings.emailNotValid.tr();
    }
    return null;
  }

  static String? validateEmailORNull(String? value, {String? message}) {
    if (value?.trim().isNotEmpty ?? false) {
      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\."
              r"[a-zA-Z]+")
          .hasMatch(value!)) {
        return message ?? 'Email is not valid!';
      }
    }
    return null;
  }

  static String? validatePositiveInteger(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr();
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return AppStrings.notAValidValue.tr();
    }
    return null; // Valid input
  }

  static String? validatePositiveDouble(String? value,
      {double? max, double? min}) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField.tr();
    }
    double? val = double.tryParse(value);
    if (val == null || (val > (max ?? 999)) || (val < (min ?? 0))) {
      return AppStrings.notAValidValue.tr();
    }

    return null; // Valid input
  }

  static String? validatePhone(String? phone, {CountryModel? country}) {
    if (phone == null || phone.isEmpty) {
      return AppStrings.requiredField.tr();
    } else if (isNumeric(phone) == false) {
      return AppStrings.notAValidValue.tr();
    } else if (country != null && phone.startsWith(country.code.substring(1))) {
      return AppStrings.notAValidValue.tr();
    } else {
      return null;
    }
  }
 static String? isValidGoogleMapLink(String? link) {
   if (link == null || link.isEmpty) {
     return AppStrings.requiredField.tr();
   }

   final host = link.toLowerCase();
   if (host.contains('google') ||host.contains('goo.g') ||
       (link.contains('/maps'))) {
     return null; // Valid
   }

   return AppStrings.invalidGoogleMapLink;
  }
  static String? validateDropDown( value, {String? message}) {
    if (value == null) {
      return message ?? AppStrings.requiredField.tr();
    }
    return null;
  }
}
