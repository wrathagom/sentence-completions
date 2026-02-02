import 'package:uuid/uuid.dart';

import '../datasources/local/saved_stem_datasource.dart';
import '../models/ai_suggestion.dart';
import '../models/saved_stem.dart';
import '../models/stem.dart';

class SavedStemRepository {
  final SavedStemDatasource _datasource;
  final Uuid _uuid = const Uuid();

  SavedStemRepository({required SavedStemDatasource datasource})
      : _datasource = datasource;

  Future<SavedStem> saveStem({
    required Stem stem,
    String? sourceEntryId,
  }) async {
    final savedStem = SavedStem(
      id: _uuid.v4(),
      stemId: stem.id,
      stemText: stem.text,
      categoryId: stem.categoryId,
      savedAt: DateTime.now(),
      sourceEntryId: sourceEntryId,
    );
    await _datasource.insertSavedStem(savedStem);
    return savedStem;
  }

  Future<SavedStem> saveAiSuggestion({
    required AISuggestion suggestion,
    String? sourceEntryId,
  }) async {
    final savedStem = SavedStem(
      id: _uuid.v4(),
      stemId: 'ai_${suggestion.tempId}',
      stemText: suggestion.text,
      categoryId: 'ai_generated',
      savedAt: DateTime.now(),
      sourceEntryId: sourceEntryId,
    );
    await _datasource.insertSavedStem(savedStem);
    return savedStem;
  }

  Future<List<SavedStem>> getAllSavedStems() {
    return _datasource.getAllSavedStems();
  }

  Future<SavedStem?> getSavedStemById(String id) {
    return _datasource.getSavedStemById(id);
  }

  Future<void> deleteSavedStem(String id) {
    return _datasource.deleteSavedStem(id);
  }

  Future<void> deleteSavedStemByStemId(String stemId) {
    return _datasource.deleteSavedStemByStemId(stemId);
  }

  Future<int> getSavedStemCount() {
    return _datasource.getSavedStemCount();
  }

  Future<bool> isStemSaved(String stemId) {
    return _datasource.isStemSaved(stemId);
  }

  Future<void> restoreSavedStem(SavedStem savedStem) async {
    await _datasource.insertSavedStem(savedStem);
  }
}
