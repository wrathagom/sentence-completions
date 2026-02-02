import 'package:sqflite/sqflite.dart';

import '../../models/stem_rating.dart';
import 'database_helper.dart';

class StemRatingDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertRating(StemRating rating) async {
    final db = await _db;
    await db.insert(
      'stem_ratings',
      rating.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRating(StemRating rating) async {
    final db = await _db;
    await db.update(
      'stem_ratings',
      rating.toMap(),
      where: 'id = ?',
      whereArgs: [rating.id],
    );
  }

  Future<void> deleteRating(String id) async {
    final db = await _db;
    await db.delete(
      'stem_ratings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<StemRating?> getRatingById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'stem_ratings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return StemRating.fromMap(maps.first);
  }

  Future<StemRating?> getRatingByStemId(String stemId) async {
    final db = await _db;
    final maps = await db.query(
      'stem_ratings',
      where: 'stem_id = ?',
      whereArgs: [stemId],
      orderBy: 'rated_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return StemRating.fromMap(maps.first);
  }

  Future<StemRating?> getRatingByEntryId(String entryId) async {
    final db = await _db;
    final maps = await db.query(
      'stem_ratings',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return StemRating.fromMap(maps.first);
  }

  Future<List<StemRating>> getAllRatings() async {
    final db = await _db;
    final maps = await db.query(
      'stem_ratings',
      orderBy: 'rated_at DESC',
    );
    return maps.map((map) => StemRating.fromMap(map)).toList();
  }

  Future<List<StemRating>> getRatingsByValue(StemRatingValue value) async {
    final db = await _db;
    final maps = await db.query(
      'stem_ratings',
      where: 'rating = ?',
      whereArgs: [value.value],
      orderBy: 'rated_at DESC',
    );
    return maps.map((map) => StemRating.fromMap(map)).toList();
  }
}
