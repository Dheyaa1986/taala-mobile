import 'package:intl/intl.dart';

extension NumberExtension on num {
  String get toThousandsString => NumberFormat('#,###').format(this);
  String get toArabic {
    final arabicNumbers = [
      '\u0660',
      '\u0661',
      '\u0662',
      '\u0663',
      '\u0664',
      '\u0665',
      '\u0666',
      '\u0667',
      '\u0668',
      '\u0669',
    ];

    return toString().split('').map((char) {
      if (char == '.') return ',';
      return arabicNumbers[int.parse(char)];
    }).join();
  }
}
