import 'package:sqflite/sqflite.dart';

import '../../models/entry_reaction.dart';
import 'database_helper.dart';

class ReactionDatasource {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> insertReaction(EntryReaction reaction) async {
    final db = await _db;
    await db.insert(
      'entry_reactions',
      reaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateReaction(EntryReaction reaction) async {
    final db = await _db;
    await db.update(
      'entry_reactions',
      reaction.toMap(),
      where: 'id = ?',
      whereArgs: [reaction.id],
    );
  }

  Future<void> deleteReaction(String id) async {
    final db = await _db;
    await db.delete(
      'entry_reactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<EntryReaction?> getReactionById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'entry_reactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return EntryReaction.fromMap(maps.first);
  }

  Future<List<EntryReaction>> getReactionsForEntry(String entryId) async {
    final db = await _db;
    final maps = await db.query(
      'entry_reactions',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EntryReaction.fromMap(map)).toList();
  }

  Future<List<EntryReaction>> getAllReactions() async {
    final db = await _db;
    final maps = await db.query(
      'entry_reactions',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EntryReaction.fromMap(map)).toList();
  }

  Future<void> deleteReactionsForEntry(String entryId) async {
    final db = await _db;
    await db.delete(
      'entry_reactions',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
  }
}
