import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/goal.dart';
import '../../data/models/saved_stem.dart';
import '../../data/models/user_settings.dart';
import '../../data/models/category.dart';
import '../../data/models/stem.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/saved_stem_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/stem_repository.dart';

class ImportResult {
  final bool success;
  final int entriesImported;
  final int goalsImported;
  final int savedStemsImported;
  final bool settingsImported;
  final List<String> errors;
  final String? errorMessage;

  const ImportResult({
    required this.success,
    this.entriesImported = 0,
    this.goalsImported = 0,
    this.savedStemsImported = 0,
    this.settingsImported = false,
    this.errors = const [],
    this.errorMessage,
  });

  factory ImportResult.success({
    required int entriesImported,
    int goalsImported = 0,
    int savedStemsImported = 0,
    bool settingsImported = false,
  }) {
    return ImportResult(
      success: true,
      entriesImported: entriesImported,
      goalsImported: goalsImported,
      savedStemsImported: savedStemsImported,
      settingsImported: settingsImported,
    );
  }

  factory ImportResult.failure(String message) {
    return ImportResult(
      success: false,
      errorMessage: message,
    );
  }

  factory ImportResult.partial({
    required int entriesImported,
    required List<String> errors,
    int goalsImported = 0,
    int savedStemsImported = 0,
    bool settingsImported = false,
  }) {
    return ImportResult(
      success: entriesImported > 0,
      entriesImported: entriesImported,
      goalsImported: goalsImported,
      savedStemsImported: savedStemsImported,
      settingsImported: settingsImported,
      errors: errors,
    );
  }
}

class ImportService {
  static const String _customCategoryId = 'custom_imported';
  static const String _customCategoryName = 'Custom';
  static const String _customCategoryEmoji = '📝';

  final EntryRepository _entryRepository;
  final StemRepository _stemRepository;
  final SettingsRepository _settingsRepository;
  final GoalRepository _goalRepository;
  final SavedStemRepository _savedStemRepository;
  final Uuid _uuid;
  String? _cachedCustomCategoryId;

  ImportService({
    required EntryRepository entryRepository,
    required StemRepository stemRepository,
    required SettingsRepository settingsRepository,
    required GoalRepository goalRepository,
    required SavedStemRepository savedStemRepository,
    Uuid? uuid,
  })  : _entryRepository = entryRepository,
        _stemRepository = stemRepository,
        _settingsRepository = settingsRepository,
        _goalRepository = goalRepository,
        _savedStemRepository = savedStemRepository,
        _uuid = uuid ?? const Uuid();

  /// Import entries from a user-selected JSON file
  Future<ImportResult> importFromFile() async {
    try {
      // Open file picker for JSON files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Export File',
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.failure('Import cancelled');
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return ImportResult.failure('Could not access file');
      }

      return await importFromPath(filePath);
    } catch (e) {
      return ImportResult.failure('Import failed: $e');
    }
  }

  /// Import entries from a specific file path
  Future<ImportResult> importFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.failure('File not found');
      }

      final content = await file.readAsString();
      return await importFromJson(content);
    } catch (e) {
      return ImportResult.failure('Import failed: $e');
    }
  }

  /// Import entries from JSON string content
  Future<ImportResult> importFromJson(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;
      return await _processImportData(data);
    } on FormatException catch (e) {
      return ImportResult.failure('Invalid JSON format: $e');
    } catch (e) {
      return ImportResult.failure('Import failed: $e');
    }
  }

  Future<ImportResult> _processImportData(Map<String, dynamic> data) async {
    // Validate structure
    if (!data.containsKey('entries')) {
      return ImportResult.failure('Invalid export format: missing entries');
    }

    final entriesList = data['entries'] as List<dynamic>;
    if (entriesList.isEmpty) {
      return ImportResult.failure('No entries to import');
    }

    // Import settings if present
    var settingsImported = false;
    if (data.containsKey('settings')) {
      try {
        await _importSettings(data['settings'] as Map<String, dynamic>);
        settingsImported = true;
      } catch (e) {
        // Settings import failed, but continue with entries
      }
    }

    // Import goals if present
    var goalsImported = 0;
    if (data.containsKey('goals')) {
      try {
        goalsImported = await _importGoals(data['goals'] as List<dynamic>);
      } catch (e) {
        // Goals import failed, but continue with entries
      }
    }

    // Import saved stems if present
    var savedStemsImported = 0;
    if (data.containsKey('savedStems')) {
      try {
        savedStemsImported = await _importSavedStems(data['savedStems'] as List<dynamic>);
      } catch (e) {
        // Saved stems import failed, but continue with entries
      }
    }

    // Get all stems for lookup
    final stems = await _stemRepository.getAllStems();
    final stemsByText = {for (final stem in stems) stem.text: stem};

    // Get all categories
    final categories = await _stemRepository.getAllCategories();
    final categoriesById = {for (final cat in categories) cat.id: cat};

    final errors = <String>[];
    var importedCount = 0;

    for (var i = 0; i < entriesList.length; i++) {
      try {
        final entryData = entriesList[i] as Map<String, dynamic>;
        await _importEntry(entryData, stemsByText, categoriesById);
        importedCount++;
      } catch (e) {
        errors.add('Entry ${i + 1}: $e');
      }
    }

    if (importedCount == 0 && errors.isNotEmpty) {
      return ImportResult.failure('All entries failed to import: ${errors.first}');
    }

    return ImportResult.partial(
      entriesImported: importedCount,
      errors: errors,
      goalsImported: goalsImported,
      savedStemsImported: savedStemsImported,
      settingsImported: settingsImported,
    );
  }

  Future<void> _importSettings(Map<String, dynamic> settingsData) async {
    // Import privacy mode (journal vs private mode)
    if (settingsData.containsKey('privacyMode')) {
      final privacyMode = settingsData['privacyMode'] as bool;
      await _settingsRepository.setPrivacyMode(privacyMode);
    }

    // Import guided mode type
    if (settingsData.containsKey('guidedModeType')) {
      final guidedModeIndex = settingsData['guidedModeType'] as int;
      if (guidedModeIndex >= 0 && guidedModeIndex < GuidedModeType.values.length) {
        await _settingsRepository.setGuidedModeType(GuidedModeType.values[guidedModeIndex]);
      }
    }

    // Import theme mode
    if (settingsData.containsKey('themeMode')) {
      final themeModeIndex = settingsData['themeMode'] as int;
      if (themeModeIndex >= 0 && themeModeIndex < ThemeModePreference.values.length) {
        await _settingsRepository.setThemeMode(ThemeModePreference.values[themeModeIndex]);
      }
    }

    // Import color theme
    if (settingsData.containsKey('colorTheme')) {
      final colorThemeIndex = settingsData['colorTheme'] as int;
      if (colorThemeIndex >= 0 && colorThemeIndex < ColorTheme.values.length) {
        await _settingsRepository.setColorTheme(ColorTheme.values[colorThemeIndex]);
      }
    }

    // Import card glow intensity
    if (settingsData.containsKey('cardGlowIntensity')) {
      final cardGlowIndex = settingsData['cardGlowIntensity'] as int;
      if (cardGlowIndex >= 0 && cardGlowIndex < CardGlowIntensity.values.length) {
        await _settingsRepository.setCardGlowIntensity(CardGlowIntensity.values[cardGlowIndex]);
      }
    }

    // Import background pattern
    if (settingsData.containsKey('backgroundPattern')) {
      final bgPatternIndex = settingsData['backgroundPattern'] as int;
      if (bgPatternIndex >= 0 && bgPatternIndex < BackgroundPattern.values.length) {
        await _settingsRepository.setBackgroundPattern(BackgroundPattern.values[bgPatternIndex]);
      }
    }
  }

  Future<int> _importGoals(List<dynamic> goalsList) async {
    var imported = 0;
    for (final goalData in goalsList) {
      try {
        final data = goalData as Map<String, dynamic>;
        final type = GoalType.fromValue(data['type'] as String);
        final target = data['target'] as int;
        final period = GoalPeriod.fromValue(data['period'] as String);

        await _goalRepository.createGoal(
          type: type,
          target: target,
          period: period,
        );
        imported++;
      } catch (e) {
        // Skip failed goals
      }
    }
    return imported;
  }

  Future<int> _importSavedStems(List<dynamic> savedStemsList) async {
    var imported = 0;
    for (final stemData in savedStemsList) {
      try {
        final data = stemData as Map<String, dynamic>;
        final stemText = data['stemText'] as String;
        final categoryId = data['categoryId'] as String;
        final savedAtStr = data['savedAt'] as String?;
        final savedAt = savedAtStr != null ? DateTime.parse(savedAtStr) : DateTime.now();

        final savedStem = SavedStem(
          id: _uuid.v4(),
          stemId: _uuid.v4(), // Generate new stem ID for imported stems
          stemText: stemText,
          categoryId: categoryId,
          savedAt: savedAt,
          sourceEntryId: null, // Don't preserve source entry ID as entries get new IDs
        );

        await _savedStemRepository.restoreSavedStem(savedStem);
        imported++;
      } catch (e) {
        // Skip failed saved stems
      }
    }
    return imported;
  }

  Future<void> _importEntry(
    Map<String, dynamic> data,
    Map<String, Stem> stemsByText,
    Map<String, Category> categoriesById,
  ) async {
    // Required fields
    final stemText = data['stemText'] as String?;
    final completion = data['completion'] as String?;
    final createdAtStr = data['createdAt'] as String?;

    if (stemText == null || stemText.isEmpty) {
      throw Exception('Missing stemText');
    }
    if (completion == null || completion.isEmpty) {
      throw Exception('Missing completion');
    }
    if (createdAtStr == null) {
      throw Exception('Missing createdAt');
    }

    // Parse and preserve the original creation date
    final createdAt = DateTime.parse(createdAtStr);

    // Try to find stem by text
    final stem = stemsByText[stemText];
    String stemId;
    String categoryId;

    if (stem != null) {
      stemId = stem.id;
      categoryId = stem.categoryId;
    } else {
      final providedCategoryId = data['categoryId'] as String?;
      if (providedCategoryId != null &&
          categoriesById.containsKey(providedCategoryId)) {
        categoryId = providedCategoryId;
      } else {
        categoryId = await _getOrCreateCustomCategory(categoriesById);
      }

      stemId = _uuid.v4();
      final newStem = Stem(
        id: stemId,
        text: stemText,
        categoryId: categoryId,
        keywords: const [],
        difficultyLevel: 1,
        isFoundational: false,
      );
      await _stemRepository.upsertStem(newStem);
      stemsByText[stemText] = newStem;
    }

    // Optional fields
    final preMoodValue = data['preMoodValue'] as int?;
    final postMoodValue = data['postMoodValue'] as int?;
    final isFavorite = data['isFavorite'] as bool? ?? false;
    final suggestedStemsList = data['suggestedStems'] as List<dynamic>?;
    final suggestedStems = suggestedStemsList?.cast<String>();

    // Create entry with new UUID to avoid conflicts
    // Preserve original creation date and skip resurfacing scheduling for imports
    final entry = await _entryRepository.createEntry(
      stemId: stemId,
      stemText: stemText,
      completion: completion,
      categoryId: categoryId,
      preMoodValue: preMoodValue,
      postMoodValue: postMoodValue,
      createdAt: createdAt,
      scheduleResurfacing: false,
    );

    // Mark as favorite if needed (toggle sets it to true since it starts false)
    if (isFavorite) {
      await _entryRepository.toggleFavorite(entry.id);
    }

    // Update entry with suggested stems if present
    if (suggestedStems != null && suggestedStems.isNotEmpty) {
      await _entryRepository.updateEntrySuggestions(entry.id, suggestedStems);
    }
  }

  Future<String> _getOrCreateCustomCategory(
    Map<String, Category> categoriesById,
  ) async {
    if (categoriesById.containsKey(_customCategoryId)) {
      _cachedCustomCategoryId = _customCategoryId;
      return _customCategoryId;
    }
    if (_cachedCustomCategoryId != null) return _cachedCustomCategoryId!;

    final sortOrder = categoriesById.isEmpty
        ? 0
        : categoriesById.values
                .map((c) => c.sortOrder)
                .reduce(max) +
            1;

    final category = Category(
      id: _customCategoryId,
      name: _customCategoryName,
      parentId: null,
      emoji: _customCategoryEmoji,
      sortOrder: sortOrder,
    );

    await _stemRepository.upsertCategory(category);
    categoriesById[_customCategoryId] = category;
    _cachedCustomCategoryId = _customCategoryId;
    return _customCategoryId;
  }
}
