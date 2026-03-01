import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;  // table_calendar 用 tc 前缀

import '../providers/calendar_provider.dart' as my;  // 自己的 provider 用 my 前缀
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../utils/constants.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(my.selectedDateProvider);  // 加 my. 前缀
    final focusedDate = ref.watch(my.focusedDateProvider);    // 加 my. 前缀
    final calendarFormat = ref.watch(my.calendarFormatProvider); // 加 my. 前缀
    final todos = ref.watch(todoListProvider);

    // 构建事件标记
    final events = _buildEvents(todos);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: tc.TableCalendar(  // table_calendar 用 tc. 前缀
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDate,
          selectedDayPredicate: (day) => tc.isSameDay(selectedDate, day), // tc.isSameDay
          calendarFormat: _getTableCalendarFormat(calendarFormat),
          availableCalendarFormats: const {
            tc.CalendarFormat.month: '月',
            tc.CalendarFormat.twoWeeks: '双周',
            tc.CalendarFormat.week: '周',
          },
          onDaySelected: (selected, focused) {
            ref.read(my.selectedDateProvider.notifier).state = selected;
            ref.read(my.focusedDateProvider.notifier).state = focused;
          },
          onFormatChanged: (format) {
            ref.read(my.calendarFormatProvider.notifier).state = 
                _fromTableCalendarFormat(format);
          },
          onPageChanged: (focused) {
            ref.read(my.focusedDateProvider.notifier).state = focused;
          },
          eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: tc.CalendarStyle(
            markersMaxCount: 3,
            markerSize: 6,
            markerDecoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            weekendTextStyle: const TextStyle(color: AppConstants.accentColor),
          ),
          headerStyle: tc.HeaderStyle(
            formatButtonVisible: true,
            formatButtonDecoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: const TextStyle(color: AppConstants.primaryColor),
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppConstants.primaryColor),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppConstants.primaryColor),
          ),
          daysOfWeekStyle: const tc.DaysOfWeekStyle(
            weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.accentColor,
            ),
          ),
          calendarBuilders: tc.CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              
              final hasCompleted = events.any((e) => (e as Map)['completed'] == true);
              final hasPending = events.any((e) => (e as Map)['completed'] == false);
              
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasPending)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: AppConstants.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasCompleted)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Map<DateTime, List<Map<String, dynamic>>> _buildEvents(List<Todo> todos) {
    final events = <DateTime, List<Map<String, dynamic>>>{};
    
    for (final todo in todos) {
      if (todo.dueDate != null) {
        final date = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
        events.putIfAbsent(date, () => []);
        events[date]!.add({
          'id': todo.id,
          'completed': todo.isCompleted,
          'priority': todo.priority,
        });
      }
    }
    
    return events;
  }

  // 你的枚举 -> table_calendar 的枚举
  tc.CalendarFormat _getTableCalendarFormat(my.CalendarFormat format) {
    switch (format) {
      case my.CalendarFormat.month:
        return tc.CalendarFormat.month;
      case my.CalendarFormat.twoWeeks:
        return tc.CalendarFormat.twoWeeks;
      case my.CalendarFormat.week:
        return tc.CalendarFormat.week;
    }
  }

  // table_calendar 的枚举 -> 你的枚举
  my.CalendarFormat _fromTableCalendarFormat(tc.CalendarFormat format) {
    switch (format) {
      case tc.CalendarFormat.month:
        return my.CalendarFormat.month;
      case tc.CalendarFormat.twoWeeks:
        return my.CalendarFormat.twoWeeks;
      case tc.CalendarFormat.week:
        return my.CalendarFormat.week;

    }
  }
}