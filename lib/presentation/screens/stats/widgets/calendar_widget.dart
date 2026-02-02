import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../providers/providers.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  final void Function(DateTime date, Set<DateTime> completionDates) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.onDaySelected,
  });

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completionDatesAsync =
        ref.watch(completionDatesForMonthProvider(_focusedDay));

    return completionDatesAsync.when(
      data: (completionDates) => _buildCalendar(colorScheme, completionDates),
      loading: () => _buildCalendar(colorScheme, {}),
      error: (e, s) => _buildCalendar(colorScheme, {}),
    );
  }

  Widget _buildCalendar(ColorScheme colorScheme, Set<DateTime> completionDates) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: colorScheme.onSurface,
                ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: colorScheme.onSurface,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            todayTextStyle: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            weekendTextStyle: TextStyle(color: colorScheme.onSurface),
            disabledTextStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              if (completionDates.contains(normalizedDay)) {
                return _buildCompletedDay(context, day, colorScheme);
              }
              return null;
            },
            todayBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final hasEntry = completionDates.contains(normalizedDay);
              return _buildTodayDay(context, day, colorScheme, hasEntry);
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            final normalizedDay =
                DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            if (completionDates.contains(normalizedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDaySelected(selectedDay, completionDates);
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCompletedDay(
      BuildContext context, DateTime day, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayDay(BuildContext context, DateTime day,
      ColorScheme colorScheme, bool hasEntry) {
    if (hasEntry) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
