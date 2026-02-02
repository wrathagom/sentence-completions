import 'package:sqflite/sqflite.dart';

import '../../models/category.dart';
import '../../models/stem.dart';
import 'database_helper.dart';

class StemLocalDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertStem(Stem stem) async {
    final db = await _db;
    await db.insert(
      'stems',
      stem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCategory(Category category) async {
    final db = await _db;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertStems(List<Stem> stems) async {
    final db = await _db;
    final batch = db.batch();
    for (final stem in stems) {
      batch.insert(
        'stems',
        stem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertCategories(List<Category> categories) async {
    final db = await _db;
    final batch = db.batch();
    for (final category in categories) {
      batch.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Stem>> getAllStems() async {
    final db = await _db;
    final maps = await db.query('stems');
    return maps.map((map) => Stem.fromMap(map)).toList();
  }

  Future<List<Stem>> getStemsByCategory(String categoryId) async {
    final db = await _db;
    final maps = await db.query(
      'stems',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((map) => Stem.fromMap(map)).toList();
  }

  Future<Stem?> getStemById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'stems',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Stem.fromMap(maps.first);
  }

  Future<Stem?> getRandomStem({Set<String>? excludeStemIds}) async {
    final db = await _db;

    if (excludeStemIds != null && excludeStemIds.isNotEmpty) {
      final placeholders = List.filled(excludeStemIds.length, '?').join(', ');
      final maps = await db.rawQuery(
        'SELECT * FROM stems WHERE id NOT IN ($placeholders) ORDER BY RANDOM() LIMIT 1',
        excludeStemIds.toList(),
      );
      if (maps.isEmpty) return null;
      return Stem.fromMap(maps.first);
    }

    final maps = await db.rawQuery(
      'SELECT * FROM stems ORDER BY RANDOM() LIMIT 1',
    );
    if (maps.isEmpty) return null;
    return Stem.fromMap(maps.first);
  }

  Future<Stem?> getRandomStemByCategory(
    String categoryId, {
    Set<String>? excludeStemIds,
  }) async {
    final db = await _db;

    if (excludeStemIds != null && excludeStemIds.isNotEmpty) {
      final placeholders = List.filled(excludeStemIds.length, '?').join(', ');
      final maps = await db.rawQuery(
        'SELECT * FROM stems WHERE category_id = ? AND id NOT IN ($placeholders) ORDER BY RANDOM() LIMIT 1',
        [categoryId, ...excludeStemIds],
      );
      if (maps.isEmpty) return null;
      return Stem.fromMap(maps.first);
    }

    final maps = await db.rawQuery(
      'SELECT * FROM stems WHERE category_id = ? ORDER BY RANDOM() LIMIT 1',
      [categoryId],
    );
    if (maps.isEmpty) return null;
    return Stem.fromMap(maps.first);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _db;
    final maps = await db.query(
      'categories',
      orderBy: 'sort_order ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('stems');
    await db.delete('categories');
  }

  Future<int> getStemCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM stems');
    return result.first['count'] as int;
  }

  Future<List<Stem>> getStemsByKeywords({
    required List<String> keywords,
    required String excludeStemId,
    int limit = 5,
  }) async {
    if (keywords.isEmpty) {
      return [];
    }

    final db = await _db;

    // Build a query that counts keyword matches for each stem
    // Keywords are stored as comma-separated values in the keywords column
    final keywordConditions = keywords
        .map((k) => "LOWER(keywords) LIKE '%${k.toLowerCase()}%'")
        .join(' OR ');

    final countExpressions = keywords
        .map((k) => "CASE WHEN LOWER(keywords) LIKE '%${k.toLowerCase()}%' THEN 1 ELSE 0 END")
        .join(' + ');

    final query = '''
      SELECT *, ($countExpressions) as match_count
      FROM stems
      WHERE id != ? AND ($keywordConditions)
      ORDER BY match_count DESC, RANDOM()
      LIMIT ?
    ''';

    final maps = await db.rawQuery(query, [excludeStemId, limit]);
    return maps.map((map) => Stem.fromMap(map)).toList();
  }

  Future<List<Stem>> getRandomStems({
    required String excludeStemId,
    int limit = 3,
  }) async {
    final db = await _db;
    final maps = await db.rawQuery(
      'SELECT * FROM stems WHERE id != ? ORDER BY RANDOM() LIMIT ?',
      [excludeStemId, limit],
    );
    return maps.map((map) => Stem.fromMap(map)).toList();
  }
}
