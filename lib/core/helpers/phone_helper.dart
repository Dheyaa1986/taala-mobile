import '../countries/data/model/country_model.dart';

class PhoneFormatterHelper {
  static String formatPhone(String phone, CountryModel? country) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';

    final digits = trimmed.replaceAll(RegExp(r'\s+'), '');
    final countryCode = country?.code.replaceAll('+', '') ?? '';

    if (countryCode.isEmpty) {
      return digits.startsWith('0') ? digits.substring(1) : digits;
    }

    if (digits.startsWith('0')) {
      return '$countryCode${digits.substring(1)}';
    }

    if (digits.startsWith(countryCode)) {
      return digits;
    }

    if (digits.startsWith('+$countryCode')) {
      return digits.substring(1);
    }

    return '$countryCode$digits';
  }
}
