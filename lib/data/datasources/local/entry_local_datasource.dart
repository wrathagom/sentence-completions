import 'package:sqflite/sqflite.dart';

import '../../models/entry.dart';
import 'database_helper.dart';

class EntryLocalDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertEntry(Entry entry) async {
    final db = await _db;
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEntry(Entry entry) async {
    final db = await _db;
    await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(String id) async {
    final db = await _db;
    await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Entry?> getEntryById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Entry.fromMap(maps.first);
  }

  Future<List<Entry>> getAllEntries() async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  Future<List<Entry>> getEntriesByCategory(String categoryId) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  Future<List<Entry>> getEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  Future<Entry?> getEntryForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'created_at >= ? AND created_at < ? AND parent_entry_id IS NULL',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Entry.fromMap(maps.first);
  }

  Future<int> getEntryCountForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM entries WHERE created_at >= ? AND created_at < ? AND parent_entry_id IS NULL',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.first['count'] as int;
  }

  Future<bool> hasEntryForToday() async {
    final entry = await getEntryForDate(DateTime.now());
    return entry != null;
  }

  Future<List<Entry>> searchEntries(String query) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'completion LIKE ? OR stem_text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  Future<List<Entry>> getEntriesByStemId(String stemId) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'stem_id = ?',
      whereArgs: [stemId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  Future<List<Entry>> getResurfacedEntries(String parentEntryId) async {
    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'parent_entry_id = ?',
      whereArgs: [parentEntryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }

  /// Returns all distinct dates that have entries (excluding resurfaced entries).
  Future<List<DateTime>> getCompletionDates() async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT date(created_at) as date_only
      FROM entries
      WHERE parent_entry_id IS NULL
      ORDER BY date_only DESC
      ''',
    );
    return result
        .map((row) => DateTime.parse(row['date_only'] as String))
        .toList();
  }

  /// Returns all entries for a specific date (both original and resurfaced).
  Future<List<Entry>> getAllEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _db;
    final maps = await db.query(
      'entries',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Entry.fromMap(map)).toList();
  }
}
