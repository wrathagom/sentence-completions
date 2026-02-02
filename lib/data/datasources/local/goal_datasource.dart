import 'package:sqflite/sqflite.dart';

import '../../models/goal.dart';
import 'database_helper.dart';

class GoalDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertGoal(Goal goal) async {
    final db = await _db;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await _db;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await _db;
    await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Goal?> getGoalById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Goal.fromMap(maps.first);
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await _db;
    final maps = await db.query(
      'goals',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<List<Goal>> getActiveGoals() async {
    final db = await _db;
    final maps = await db.query(
      'goals',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<void> setGoalActive(String id, bool isActive) async {
    final db = await _db;
    await db.update(
      'goals',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal Progress methods
  Future<void> insertProgress(GoalProgress progress) async {
    final db = await _db;
    await db.insert(
      'goal_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProgress(GoalProgress progress) async {
    final db = await _db;
    await db.update(
      'goal_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<GoalProgress?> getProgressById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'goal_progress',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return GoalProgress.fromMap(maps.first);
  }

  Future<GoalProgress?> getCurrentProgress(String goalId, DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String();
    final maps = await db.query(
      'goal_progress',
      where: 'goal_id = ? AND period_start <= ? AND period_end >= ?',
      whereArgs: [goalId, dateStr, dateStr],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return GoalProgress.fromMap(maps.first);
  }

  Future<List<GoalProgress>> getProgressForGoal(String goalId) async {
    final db = await _db;
    final maps = await db.query(
      'goal_progress',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'period_start DESC',
    );
    return maps.map((map) => GoalProgress.fromMap(map)).toList();
  }

  Future<void> deleteProgressForGoal(String goalId) async {
    final db = await _db;
    await db.delete(
      'goal_progress',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );
  }
}
