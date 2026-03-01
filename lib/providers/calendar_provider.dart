import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final focusedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final calendarFormatProvider = StateProvider<CalendarFormat>((ref) {
  return CalendarFormat.month;
});

enum CalendarFormat { month, twoWeeks, week }