import 'package:flutter/services.dart';
class PositiveIntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow only positive integers (digits only)
    final regExp = RegExp(r'[0-9]');
    String filteredText = newValue.text.split('').where((char) => regExp.hasMatch(char)).join();

    // Return the filtered text value
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}
class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow only valid email characters (letters, numbers, @, ., _, and -)
    final regExp = RegExp(r'^[a-zA-Z0-9@._-]+$');
    String filteredText = newValue.text.split('').where((char) => regExp.hasMatch(char)).join();

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}
class PositiveDoubleInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow only valid double numbers and ensure no negative sign
    final regex = RegExp(r'^\d*\.?\d*$');
    if (regex.hasMatch(text)) {
      return newValue;
    }

    // Reject the new value if it doesn't match
    return oldValue;
  }
}
class InputFormatter {
  static TextInputFormatter arabicInputFormatter =
  FilteringTextInputFormatter.allow(RegExp("[0-9\u0621-\u064A ]+"));
  static TextInputFormatter arabicLettersFormatter =
  FilteringTextInputFormatter.allow(RegExp("[\u0621-\u064A ]+"));
  static TextInputFormatter englishLettersFormatter =
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]+"));
  static TextInputFormatter arabicEnglishLettersFormatter =
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u0621-\u064A ]+"));
  static TextInputFormatter arabicEnglishNumbersLettersFormatter =
  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z\u0621-\u064A ]+"));
  static TextInputFormatter englishInputFormatter =
  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]"));
  static TextInputFormatter positiveNumbers =
  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d*$'));
  static TextInputFormatter intPositiveNumbers =
  FilteringTextInputFormatter.allow(RegExp('[0-9]'));




  static List<TextInputFormatter> nameFormatter = [
    arabicEnglishLettersFormatter,
    LengthLimitingTextInputFormatter(50),
  ];
  static List<TextInputFormatter> nameWithNumbersFormatter = [
    arabicEnglishNumbersLettersFormatter,
    LengthLimitingTextInputFormatter(50),
  ];

  static List<TextInputFormatter> phoneFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(11),
  ];
  static List<TextInputFormatter> emailFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9@.]+$')),
    LengthLimitingTextInputFormatter(50),
  ];
  static List<TextInputFormatter> passwordFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9@.]+$')),
    LengthLimitingTextInputFormatter(50),
  ];
}
