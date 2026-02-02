import '../../data/models/entry.dart';
import '../../data/models/stem.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/stem_repository.dart';

class CompletionService {
  final EntryRepository _entryRepository;
  final StemRepository _stemRepository;
  final SettingsRepository _settingsRepository;

  CompletionService({
    required EntryRepository entryRepository,
    required StemRepository stemRepository,
    required SettingsRepository settingsRepository,
  })  : _entryRepository = entryRepository,
        _stemRepository = stemRepository,
        _settingsRepository = settingsRepository;

  Future<bool> hasCompletedToday() {
    return _entryRepository.hasCompletedToday();
  }

  Future<Stem?> getStemForCompletion({
    String? categoryId,
    Set<String>? excludeStemIds,
  }) async {
    if (categoryId != null) {
      return _stemRepository.getRandomStemByCategory(
        categoryId,
        excludeStemIds: excludeStemIds,
      );
    }
    return _stemRepository.getRandomStem(excludeStemIds: excludeStemIds);
  }

  Future<Entry> saveCompletion({
    required Stem stem,
    required String completion,
    int? preMoodValue,
    int? postMoodValue,
  }) async {
    final entry = await _entryRepository.createEntry(
      stemId: stem.id,
      stemText: stem.text,
      completion: completion,
      categoryId: stem.categoryId,
      preMoodValue: preMoodValue,
      postMoodValue: postMoodValue,
    );

    await _settingsRepository.setLastCompletionDate(DateTime.now());

    return entry;
  }

  Future<Entry?> getTodayEntry() {
    return _entryRepository.getTodayEntry();
  }
}
