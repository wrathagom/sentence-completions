import 'package:sqflite/sqflite.dart';

import '../../models/saved_stem.dart';
import 'database_helper.dart';

class SavedStemDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertSavedStem(SavedStem savedStem) async {
    final db = await _db;
    await db.insert(
      'saved_stems',
      savedStem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavedStem>> getAllSavedStems() async {
    final db = await _db;
    final maps = await db.query(
      'saved_stems',
      orderBy: 'saved_at DESC',
    );
    return maps.map((map) => SavedStem.fromMap(map)).toList();
  }

  Future<SavedStem?> getSavedStemById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'saved_stems',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SavedStem.fromMap(maps.first);
  }

  Future<void> deleteSavedStem(String id) async {
    final db = await _db;
    await db.delete(
      'saved_stems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSavedStemByStemId(String stemId) async {
    final db = await _db;
    await db.delete(
      'saved_stems',
      where: 'stem_id = ?',
      whereArgs: [stemId],
    );
  }

  Future<int> getSavedStemCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM saved_stems');
    return result.first['count'] as int;
  }

  Future<bool> isStemSaved(String stemId) async {
    final db = await _db;
    final result = await db.query(
      'saved_stems',
      where: 'stem_id = ?',
      whereArgs: [stemId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
