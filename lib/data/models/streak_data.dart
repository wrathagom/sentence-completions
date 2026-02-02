class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalCompletionDays;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletionDays,
  });

  const StreakData.empty()
      : currentStreak = 0,
        longestStreak = 0,
        totalCompletionDays = 0;
}
