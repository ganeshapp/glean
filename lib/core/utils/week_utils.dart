class WeekUtils {
  WeekUtils._();

  static int isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekday = date.weekday;
    final weekNumber = ((dayOfYear - weekday + 10) / 7).floor();

    if (weekNumber < 1) {
      return isoWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    if (weekNumber > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < 4) return 1;
    }
    return weekNumber;
  }

  static int isoWeekYear(DateTime date) {
    final weekNum = isoWeekNumber(date);
    if (weekNum >= 52 && date.month == 1) return date.year - 1;
    if (weekNum == 1 && date.month == 12) return date.year + 1;
    return date.year;
  }

  static String weekLabel([DateTime? date]) {
    date ??= DateTime.now();
    final year = isoWeekYear(date);
    final week = isoWeekNumber(date);
    return '$year${week.toString().padLeft(2, '0')}';
  }

  static String weekDateRange([DateTime? date]) {
    date ??= DateTime.now();
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${_fmt(monday)} - ${_fmt(sunday)}';
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
