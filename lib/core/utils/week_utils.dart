import 'package:intl/intl.dart';

class WeekUtils {
  WeekUtils._();
  static DateTime _thursday(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    return day.add(Duration(days: DateTime.thursday - day.weekday));
  }

  static int isoWeekYear(DateTime date) => _thursday(date).year;
  static int isoWeekNumber(DateTime date) {
    final thursday = _thursday(date);
    return 1 +
        thursday.difference(DateTime.utc(thursday.year, 1, 1)).inDays ~/ 7;
  }

  static String weekLabel([DateTime? date]) {
    final day = date ?? DateTime.now();
    return '${isoWeekYear(day)}-W${isoWeekNumber(day).toString().padLeft(2, '0')}';
  }

  static String weekDateRange([DateTime? date]) {
    final d = date ?? DateTime.now();
    final day = DateTime.utc(d.year, d.month, d.day);
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return '${DateFormat('MMM d').format(monday)} – ${DateFormat('MMM d').format(monday.add(const Duration(days: 6)))}';
  }
}
