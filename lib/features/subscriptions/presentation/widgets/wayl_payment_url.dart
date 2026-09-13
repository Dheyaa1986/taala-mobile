class WaylPaymentUrl {
  const WaylPaymentUrl._();

  static String withProviderPhone(String paymentUrl, String? providerPhone) {
    final normalizedPhone = _normalizeIraqiPhone(providerPhone);
    if (normalizedPhone == null) {
      return paymentUrl;
    }

    final uri = Uri.tryParse(paymentUrl.trim());
    if (uri == null) {
      return paymentUrl;
    }

    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'phone': normalizedPhone,
            'phoneNumber': normalizedPhone,
          },
        )
        .toString();
  }

  static String? _normalizeIraqiPhone(String? raw) {
    final digits = raw?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) {
      return null;
    }

    if (digits.startsWith('964') && digits.length >= 12) {
      return digits.substring(3);
    }

    if (digits.startsWith('0') && digits.length >= 10) {
      return digits.substring(1);
    }

    return digits.length >= 9 ? digits : null;
  }
}
