import 'package:uuid/uuid.dart';

import '../datasources/local/goal_datasource.dart';
import '../models/goal.dart';

class GoalRepository {
  final GoalDatasource _datasource;
  final Uuid _uuid;

  GoalRepository({
    required GoalDatasource datasource,
    Uuid? uuid,
  })  : _datasource = datasource,
        _uuid = uuid ?? const Uuid();

  Future<Goal> createGoal({
    required GoalType type,
    required int target,
    required GoalPeriod period,
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      type: type,
      target: target,
      period: period,
      createdAt: DateTime.now(),
      isActive: true,
    );
    await _datasource.insertGoal(goal);
    return goal;
  }

  Future<void> updateGoal(Goal goal) async {
    await _datasource.updateGoal(goal);
  }

  Future<void> deleteGoal(String id) async {
    await _datasource.deleteProgressForGoal(id);
    await _datasource.deleteGoal(id);
  }

  Future<Goal?> getGoalById(String id) {
    return _datasource.getGoalById(id);
  }

  Future<List<Goal>> getAllGoals() {
    return _datasource.getAllGoals();
  }

  Future<List<Goal>> getActiveGoals() {
    return _datasource.getActiveGoals();
  }

  Future<void> setGoalActive(String id, bool isActive) {
    return _datasource.setGoalActive(id, isActive);
  }

  Future<GoalProgress?> getCurrentProgress(String goalId, DateTime date) {
    return _datasource.getCurrentProgress(goalId, date);
  }

  Future<GoalProgress> getOrCreateProgress({
    required String goalId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final existing = await _datasource.getCurrentProgress(goalId, periodStart);
    if (existing != null) return existing;

    final progress = GoalProgress(
      id: _uuid.v4(),
      goalId: goalId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      achieved: 0,
    );
    await _datasource.insertProgress(progress);
    return progress;
  }

  Future<void> updateProgress(GoalProgress progress) {
    return _datasource.updateProgress(progress);
  }

  Future<List<GoalProgress>> getProgressHistory(String goalId) {
    return _datasource.getProgressForGoal(goalId);
  }
}
