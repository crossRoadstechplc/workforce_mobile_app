bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Parses API calendar dates (`YYYY-MM-DD` or ISO midnight UTC) without timezone shift.
DateTime parseCalendarDate(String value) {
  final datePart = value.split('T').first;
  final parts = datePart.split('-');
  if (parts.length == 3) {
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
  return DateTime.parse(value).toLocal();
}

bool isSameCalendarMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

DateTime normalizeDate(DateTime value) => DateTime(value.year, value.month, value.day);

DateTime monthStart(DateTime value) => DateTime(value.year, value.month);

String monthKey(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}';

DateTime parseMonthKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

int daysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

/// Days in [month], capped at [today] when [month] is the current calendar month.
List<DateTime> daysInMonthUntilToday(DateTime month, DateTime today) {
  final normalizedToday = normalizeDate(today);
  final start = monthStart(month);
  if (start.isAfter(DateTime(normalizedToday.year, normalizedToday.month))) return const [];

  final lastDay = isSameCalendarMonth(month, normalizedToday)
      ? normalizedToday.day
      : daysInMonth(month);

  return List.generate(lastDay, (i) => DateTime(month.year, month.month, i + 1));
}

List<DateTime> buildDayRange(List<String> monthKeys, DateTime today) {
  final sorted = monthKeys.map(parseMonthKey).toList()..sort((a, b) => a.compareTo(b));
  final days = <DateTime>[];
  for (final month in sorted) {
    days.addAll(daysInMonthUntilToday(month, today));
  }
  return days;
}
