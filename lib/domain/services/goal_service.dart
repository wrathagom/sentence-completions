import '../../data/models/goal.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/goal_repository.dart';
import 'streak_service.dart';

class GoalService {
  final GoalRepository _goalRepository;
  final EntryRepository _entryRepository;
  final StreakService _streakService;

  GoalService({
    required GoalRepository goalRepository,
    required EntryRepository entryRepository,
    required StreakService streakService,
  })  : _goalRepository = goalRepository,
        _entryRepository = entryRepository,
        _streakService = streakService;

  Future<List<GoalWithProgress>> getActiveGoalsWithProgress() async {
    final goals = await _goalRepository.getActiveGoals();
    final List<GoalWithProgress> result = [];

    for (final goal in goals) {
      final progress = await _calculateCurrentProgress(goal);
      result.add(GoalWithProgress(
        goal: goal,
        currentProgress: progress,
      ));
    }

    return result;
  }

  Future<GoalWithProgress?> getGoalWithProgress(String goalId) async {
    final goal = await _goalRepository.getGoalById(goalId);
    if (goal == null) return null;

    final progress = await _calculateCurrentProgress(goal);
    return GoalWithProgress(
      goal: goal,
      currentProgress: progress,
    );
  }

  Future<int> _calculateCurrentProgress(Goal goal) async {
    final now = DateTime.now();
    final (periodStart, periodEnd) = _getPeriodBounds(goal.period, now);

    switch (goal.type) {
      case GoalType.entries:
        return _countEntriesInPeriod(periodStart, periodEnd);
      case GoalType.streak:
        final streakData = await _streakService.calculateStreakData();
        return streakData.currentStreak;
    }
  }

  Future<int> _countEntriesInPeriod(DateTime start, DateTime end) async {
    final entries = await _entryRepository.getAllEntries();
    return entries.where((e) {
      return !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end);
    }).length;
  }

  (DateTime, DateTime) _getPeriodBounds(GoalPeriod period, DateTime date) {
    switch (period) {
      case GoalPeriod.daily:
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1)).subtract(
              const Duration(milliseconds: 1),
            );
        return (start, end);

      case GoalPeriod.weekly:
        // Week starts on Monday
        final weekday = date.weekday;
        final start = DateTime(date.year, date.month, date.day)
            .subtract(Duration(days: weekday - 1));
        final end = start.add(const Duration(days: 7)).subtract(
              const Duration(milliseconds: 1),
            );
        return (start, end);

      case GoalPeriod.monthly:
        final start = DateTime(date.year, date.month, 1);
        final nextMonth = date.month == 12
            ? DateTime(date.year + 1, 1, 1)
            : DateTime(date.year, date.month + 1, 1);
        final end =
            nextMonth.subtract(const Duration(milliseconds: 1));
        return (start, end);
    }
  }

  String getPeriodLabel(GoalPeriod period) {
    switch (period) {
      case GoalPeriod.daily:
        return 'Today';
      case GoalPeriod.weekly:
        return 'This week';
      case GoalPeriod.monthly:
        return 'This month';
    }
  }

  int getDaysRemainingInPeriod(GoalPeriod period) {
    final now = DateTime.now();
    final (_, end) = _getPeriodBounds(period, now);
    return end.difference(now).inDays + 1;
  }

  Future<Goal> createGoal({
    required GoalType type,
    required int target,
    required GoalPeriod period,
  }) {
    return _goalRepository.createGoal(
      type: type,
      target: target,
      period: period,
    );
  }

  Future<void> deleteGoal(String id) {
    return _goalRepository.deleteGoal(id);
  }

  Future<void> setGoalActive(String id, bool isActive) {
    return _goalRepository.setGoalActive(id, isActive);
  }

  Future<List<Goal>> getAllGoals() {
    return _goalRepository.getAllGoals();
  }
}
