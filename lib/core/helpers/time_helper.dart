import 'package:easy_localization/easy_localization.dart';
import 'package:ntp/ntp.dart';

import 'package:timeago/timeago.dart' as timeago;

import '../app_config/app_strings.dart';

class DateTimeHelper {
  static Future<DateTime> getTime() async {
    try {
      return await NTP.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return AppStrings.today.tr();
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday.tr();
    } else if (difference.inDays < 30) {
      return "${difference.inDays} ${AppStrings.days.tr()}";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() > 1 ? AppStrings.months.tr() : AppStrings.month.tr()}";
    } else {
      return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? AppStrings.years.tr() : AppStrings.year.tr()}";
    }
  }

  static String getTimeAgo({required DateTime date, required String locale}) {
    if (locale == 'ar') {
      timeago.setLocaleMessages('ar', timeago.ArMessages());
    } else {
      timeago.setLocaleMessages('en', timeago.EnMessages());
    }
    return timeago.format(date, locale: locale);
  }

  static String formatDate({required DateTime dateTime, String? formatter}) => DateFormat(formatter??'dd/MM/yyyy').format(dateTime);

  static String formatDateOrRelative(DateTime date, String locale) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM, yyyy', locale).format(date);

    // If the date is today
    if (isSameDay(date, now)) {
      return AppStrings.today.tr();
    }

    // If the date is yesterday
    else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return AppStrings.yesterday.tr();
    }

    // Otherwise, return the formatted date
    return formattedDate;
  }

// Helper function to compare if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
