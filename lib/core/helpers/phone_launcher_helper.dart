class PhoneLauncherHelper {
  static String digitsOnly(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  static String forWhatsApp(String phone) {
    var digits = digitsOnly(phone);
    if (digits.isEmpty) return '';

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith('9640')) {
      return '964${digits.substring(4)}';
    }

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.length == 10 && digits.startsWith('7')) {
      return '964$digits';
    }

    return digits;
  }

  static String forTel(String phone) {
    final digits = forWhatsApp(phone);
    return digits.isEmpty ? phone.trim() : '+$digits';
  }
}
