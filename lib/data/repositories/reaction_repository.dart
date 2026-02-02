import 'package:uuid/uuid.dart';

import '../datasources/local/reaction_datasource.dart';
import '../models/entry_reaction.dart';

class ReactionRepository {
  final ReactionDatasource _datasource;
  final Uuid _uuid;

  ReactionRepository({
    required ReactionDatasource datasource,
    Uuid? uuid,
  })  : _datasource = datasource,
        _uuid = uuid ?? const Uuid();

  Future<EntryReaction> addReaction({
    required String entryId,
    required ReactionType reactionType,
    String? note,
  }) async {
    final reaction = EntryReaction(
      id: _uuid.v4(),
      entryId: entryId,
      reactionType: reactionType,
      note: note,
      createdAt: DateTime.now(),
    );
    await _datasource.insertReaction(reaction);
    return reaction;
  }

  Future<void> updateReaction(EntryReaction reaction) async {
    await _datasource.updateReaction(reaction);
  }

  Future<void> deleteReaction(String id) async {
    await _datasource.deleteReaction(id);
  }

  Future<EntryReaction?> getReactionById(String id) {
    return _datasource.getReactionById(id);
  }

  Future<List<EntryReaction>> getReactionsForEntry(String entryId) {
    return _datasource.getReactionsForEntry(entryId);
  }

  Future<List<EntryReaction>> getAllReactions() {
    return _datasource.getAllReactions();
  }

  Future<void> deleteReactionsForEntry(String entryId) {
    return _datasource.deleteReactionsForEntry(entryId);
  }

  Future<EntryReaction> toggleReaction({
    required String entryId,
    required ReactionType reactionType,
  }) async {
    final reactions = await getReactionsForEntry(entryId);
    final existingReaction = reactions.where(
      (r) => r.reactionType == reactionType,
    ).toList();

    if (existingReaction.isNotEmpty) {
      // Remove existing reaction of same type
      await deleteReaction(existingReaction.first.id);
      // Return a dummy reaction to indicate removal (with empty id)
      return EntryReaction(
        id: '',
        entryId: entryId,
        reactionType: reactionType,
        createdAt: DateTime.now(),
      );
    } else {
      // Add new reaction
      return addReaction(entryId: entryId, reactionType: reactionType);
    }
  }
}
