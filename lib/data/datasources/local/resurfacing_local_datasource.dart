import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class ResurfacingSchedule {
  final String id;
  final String entryId;
  final DateTime scheduledDate;
  final bool completed;

  const ResurfacingSchedule({
    required this.id,
    required this.entryId,
    required this.scheduledDate,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_id': entryId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'completed': completed ? 1 : 0,
    };
  }

  factory ResurfacingSchedule.fromMap(Map<String, dynamic> map) {
    return ResurfacingSchedule(
      id: map['id'] as String,
      entryId: map['entry_id'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      completed: map['completed'] == 1,
    );
  }
}

class ResurfacingLocalDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> scheduleResurfacing(ResurfacingSchedule schedule) async {
    final db = await _db;
    await db.insert(
      'resurfacing_schedule',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markCompleted(String id) async {
    final db = await _db;
    await db.update(
      'resurfacing_schedule',
      {'completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ResurfacingSchedule>> getPendingResurfacing() async {
    final db = await _db;
    final now = DateTime.now();
    final maps = await db.query(
      'resurfacing_schedule',
      where: 'scheduled_date <= ? AND completed = 0',
      whereArgs: [now.toIso8601String()],
      orderBy: 'scheduled_date ASC',
    );
    return maps.map((map) => ResurfacingSchedule.fromMap(map)).toList();
  }

  Future<List<ResurfacingSchedule>> getScheduleForEntry(String entryId) async {
    final db = await _db;
    final maps = await db.query(
      'resurfacing_schedule',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'scheduled_date ASC',
    );
    return maps.map((map) => ResurfacingSchedule.fromMap(map)).toList();
  }

  Future<void> deleteScheduleForEntry(String entryId) async {
    final db = await _db;
    await db.delete(
      'resurfacing_schedule',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
  }
}
