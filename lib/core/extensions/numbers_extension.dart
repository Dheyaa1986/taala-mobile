import 'package:intl/intl.dart';

extension NumberExtension on num {
  String get toThousandsString => NumberFormat('#,###').format(this);
  String get toArabic {
    final arabicNumbers = [
      '\u0660', // ٠
      '\u0661', // ١
      '\u0662', // ٢
      '\u0663', // ٣
      '\u0664', // ٤
      '\u0665', // ٥
      '\u0666', // ٦
      '\u0667', // ٧
      '\u0668', // ٨
      '\u0669', // ٩
    ];

    return toString().split('').map((char) {
      if (char == '.') return ',';
      // if (!arabicNumbers.contains(char)) return char;
      return arabicNumbers[int.parse(char)];
    }).join();
  }
}
