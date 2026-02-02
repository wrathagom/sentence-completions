import '../../data/models/streak_data.dart';
import '../../data/repositories/entry_repository.dart';

class StreakService {
  final EntryRepository _entryRepository;

  StreakService({required EntryRepository entryRepository})
      : _entryRepository = entryRepository;

  /// Calculate streak data from the list of completion dates.
  Future<StreakData> calculateStreakData() async {
    final dates = await _entryRepository.getCompletionDates();

    if (dates.isEmpty) {
      return const StreakData.empty();
    }

    // Normalize dates to just date part (no time)
    final normalizedDates = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // Calculate current streak (consecutive days from today or yesterday)
    int currentStreak = 0;
    DateTime checkDate = todayNormalized;

    // Check if there's an entry today or yesterday to start the streak
    final hasEntryToday = normalizedDates.contains(todayNormalized);
    final yesterday = todayNormalized.subtract(const Duration(days: 1));
    final hasEntryYesterday = normalizedDates.contains(yesterday);

    if (!hasEntryToday && !hasEntryYesterday) {
      // Streak is broken
      currentStreak = 0;
    } else {
      // Start checking from today or yesterday
      if (!hasEntryToday) {
        checkDate = yesterday;
      }

      for (final date in normalizedDates) {
        if (date == checkDate) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(checkDate)) {
          // Gap found, streak ends
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;
    final sortedAsc = normalizedDates.reversed.toList(); // Oldest first

    for (int i = 1; i < sortedAsc.length; i++) {
      final diff = sortedAsc[i].difference(sortedAsc[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompletionDays: normalizedDates.length,
    );
  }

  /// Get completion dates for a specific month (for calendar markers).
  Future<Set<DateTime>> getCompletionDatesForMonth(DateTime month) async {
    final dates = await _entryRepository.getCompletionDates();

    return dates
        .where((d) => d.year == month.year && d.month == month.month)
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }
}
