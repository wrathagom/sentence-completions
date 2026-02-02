import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/deleted_entry.dart';
import 'database_helper.dart';

/// Local datasource for managing soft-deleted entries
class DeletedEntryDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  /// Insert a soft-deleted entry
  Future<void> insertDeletedEntry(DeletedEntry entry) async {
    final db = await _db;
    await db.insert(
      'deleted_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all soft-deleted entries
  Future<List<DeletedEntry>> getDeletedEntries() async {
    final db = await _db;
    final maps = await db.query(
      'deleted_entries',
      orderBy: 'deleted_at DESC',
    );
    return maps.map((map) => DeletedEntry.fromMap(map)).toList();
  }

  /// Get a specific deleted entry by ID
  Future<DeletedEntry?> getDeletedEntryById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'deleted_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DeletedEntry.fromMap(maps.first);
  }

  /// Get deleted entry by original ID
  Future<DeletedEntry?> getDeletedEntryByOriginalId(String originalId) async {
    final db = await _db;
    final maps = await db.query(
      'deleted_entries',
      where: 'original_id = ?',
      whereArgs: [originalId],
    );
    if (maps.isEmpty) return null;
    return DeletedEntry.fromMap(maps.first);
  }

  /// Permanently delete an entry from the deleted entries table
  Future<void> permanentlyDeleteEntry(String id) async {
    final db = await _db;
    await db.delete(
      'deleted_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all expired entries (older than retention period)
  Future<int> clearExpiredEntries() async {
    final db = await _db;
    final expirationDate = DateTime.now()
        .subtract(const Duration(days: DeletedEntry.retentionDays));

    return await db.delete(
      'deleted_entries',
      where: 'deleted_at < ?',
      whereArgs: [expirationDate.toIso8601String()],
    );
  }

  /// Get count of deleted entries
  Future<int> getDeletedEntryCount() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM deleted_entries',
    );
    return result.first['count'] as int;
  }
}
