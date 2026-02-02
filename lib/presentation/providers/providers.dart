import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/entry_local_datasource.dart';
import '../../data/datasources/local/resurfacing_local_datasource.dart';
import '../../data/datasources/local/saved_stem_datasource.dart';
import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/local/stem_local_datasource.dart';
import '../../data/datasources/remote/stems_remote_datasource.dart';
import '../../data/models/category.dart';
import '../../data/models/entry.dart';
import '../../data/models/saved_stem.dart';
import '../../data/models/stem.dart';
import '../../data/models/user_settings.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/saved_stem_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/stem_repository.dart';
import '../../data/models/analytics_data.dart';
import '../../domain/services/analytics_service.dart';
import '../../domain/services/anthropic_service.dart';
import '../../domain/services/completion_service.dart';
import '../../domain/services/export_service.dart';
import '../../domain/services/intelligent_suggestion_service.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/resurfacing_service.dart';
import '../../domain/services/streak_service.dart';
import '../../domain/services/suggestion_service.dart';
import '../../data/models/streak_data.dart';

// SharedPreferences provider - must be overridden at app startup
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// Datasource providers
final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  return SettingsLocalDatasource(ref.watch(sharedPreferencesProvider));
});

final entryLocalDatasourceProvider = Provider<EntryLocalDatasource>((ref) {
  return EntryLocalDatasource();
});

final stemLocalDatasourceProvider = Provider<StemLocalDatasource>((ref) {
  return StemLocalDatasource();
});

final resurfacingLocalDatasourceProvider =
    Provider<ResurfacingLocalDatasource>((ref) {
  return ResurfacingLocalDatasource();
});

final stemsRemoteDatasourceProvider = Provider<StemsRemoteDatasource>((ref) {
  return StemsRemoteDatasource();
});

final savedStemDatasourceProvider = Provider<SavedStemDatasource>((ref) {
  return SavedStemDatasource();
});

final secureStorageDatasourceProvider = Provider<SecureStorageDatasource>((ref) {
  return SecureStorageDatasource();
});

// Repository providers
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    datasource: ref.watch(settingsLocalDatasourceProvider),
  );
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(
    entryDatasource: ref.watch(entryLocalDatasourceProvider),
    resurfacingDatasource: ref.watch(resurfacingLocalDatasourceProvider),
  );
});

final stemRepositoryProvider = Provider<StemRepository>((ref) {
  return StemRepository(
    localDatasource: ref.watch(stemLocalDatasourceProvider),
    remoteDatasource: ref.watch(stemsRemoteDatasourceProvider),
  );
});

final savedStemRepositoryProvider = Provider<SavedStemRepository>((ref) {
  return SavedStemRepository(
    datasource: ref.watch(savedStemDatasourceProvider),
  );
});

// Service providers
final completionServiceProvider = Provider<CompletionService>((ref) {
  return CompletionService(
    entryRepository: ref.watch(entryRepositoryProvider),
    stemRepository: ref.watch(stemRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

final resurfacingServiceProvider = Provider<ResurfacingService>((ref) {
  return ResurfacingService(
    entryRepository: ref.watch(entryRepositoryProvider),
  );
});

final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService(
    stemRepository: ref.watch(stemRepositoryProvider),
  );
});

final anthropicServiceProvider = Provider<AnthropicService>((ref) {
  return AnthropicService(
    secureStorage: ref.watch(secureStorageDatasourceProvider),
  );
});

final intelligentSuggestionServiceProvider = Provider<IntelligentSuggestionService>((ref) {
  return IntelligentSuggestionService(
    suggestionService: ref.watch(suggestionServiceProvider),
    anthropicService: ref.watch(anthropicServiceProvider),
  );
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    entryRepository: ref.watch(entryRepositoryProvider),
  );
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    entryRepository: ref.watch(entryRepositoryProvider),
    stemRepository: ref.watch(stemRepositoryProvider),
  );
});

final analyticsDataProvider = FutureProvider<AnalyticsData>((ref) async {
  ref.watch(entriesProvider);
  final service = ref.watch(analyticsServiceProvider);
  return service.getAnalytics();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// API key status provider
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  final secureStorage = ref.watch(secureStorageDatasourceProvider);
  return secureStorage.hasAnthropicApiKey();
});

// State providers
final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> setOnboardingCompleted(bool completed) async {
    await _repository.setOnboardingCompleted(completed);
    state = _repository.getSettings();
  }

  Future<void> setPrivacyMode(bool enabled) async {
    await _repository.setPrivacyMode(enabled);
    state = _repository.getSettings();
  }

  Future<void> setAnalyticsEnabled(bool enabled) async {
    await _repository.setAnalyticsEnabled(enabled);
    state = _repository.getSettings();
  }

  Future<void> setAppLock({
    required bool enabled,
    required AppLockType type,
    String? pinHash,
  }) async {
    await _repository.setAppLock(
      enabled: enabled,
      type: type,
      pinHash: pinHash,
    );
    state = _repository.getSettings();
  }

  Future<void> setThemeMode(ThemeModePreference mode) async {
    await _repository.setThemeMode(mode);
    state = _repository.getSettings();
  }

  Future<void> setColorTheme(ColorTheme theme) async {
    await _repository.setColorTheme(theme);
    state = _repository.getSettings();
  }

  Future<void> setGuidedModeType(GuidedModeType type) async {
    await _repository.setGuidedModeType(type);
    state = _repository.getSettings();
  }

  Future<void> setAiConsentEnabled(bool enabled) async {
    await _repository.setAiConsentEnabled(enabled);
    state = _repository.getSettings();
  }

  Future<void> setTitleBarStyle(TitleBarStyle style) async {
    await _repository.setTitleBarStyle(style);
    state = _repository.getSettings();
  }

  Future<void> setReminderSettings(String jsonSettings) async {
    await _repository.setReminderSettings(jsonSettings);
    state = _repository.getSettings();
  }
}

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(stemRepositoryProvider);
  return repository.getAllCategories();
});

// Stems provider
final stemsProvider = FutureProvider<List<Stem>>((ref) async {
  final repository = ref.watch(stemRepositoryProvider);
  return repository.getAllStems();
});

final stemsByCategoryProvider =
    FutureProvider.family<List<Stem>, String>((ref, categoryId) async {
  final repository = ref.watch(stemRepositoryProvider);
  return repository.getStemsByCategory(categoryId);
});

// Entries provider
final entriesProvider = FutureProvider<List<Entry>>((ref) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getAllEntries();
});

// Entry by ID provider
final entryByIdProvider = FutureProvider.family<Entry?, String>((ref, id) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getEntryById(id);
});

final todayEntryProvider = FutureProvider<Entry?>((ref) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getTodayEntry();
});

final hasCompletedTodayProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(completionServiceProvider);
  return service.hasCompletedToday();
});

final todayEntryCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getTodayEntryCount();
});

// Resurfacing providers
final pendingResurfacingProvider =
    FutureProvider<List<ResurfacingEntry>>((ref) async {
  final service = ref.watch(resurfacingServiceProvider);
  return service.getPendingResurfacing();
});

// Selected stem for completion
final selectedStemProvider = StateProvider<Stem?>((ref) => null);

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEntriesProvider = FutureProvider<List<Entry>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(entryRepositoryProvider);

  if (query.isEmpty) {
    return repository.getAllEntries();
  }
  return repository.searchEntries(query);
});

// Saved stems providers
final savedStemsProvider = FutureProvider<List<SavedStem>>((ref) async {
  final repository = ref.watch(savedStemRepositoryProvider);
  return repository.getAllSavedStems();
});

final savedStemCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(savedStemRepositoryProvider);
  return repository.getSavedStemCount();
});

// Streak providers
final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(
    entryRepository: ref.watch(entryRepositoryProvider),
  );
});

final streakDataProvider = FutureProvider<StreakData>((ref) async {
  // Watch entries to auto-refresh when entries change
  ref.watch(entriesProvider);
  final service = ref.watch(streakServiceProvider);
  return service.calculateStreakData();
});

final completionDatesForMonthProvider =
    FutureProvider.family<Set<DateTime>, DateTime>((ref, month) async {
  // Watch entries to auto-refresh when entries change
  ref.watch(entriesProvider);
  final service = ref.watch(streakServiceProvider);
  return service.getCompletionDatesForMonth(month);
});

final entriesForDateProvider =
    FutureProvider.family<List<Entry>, DateTime>((ref, date) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getAllEntriesForDate(date);
});

final selectedCalendarDateProvider = StateProvider<DateTime?>((ref) => null);

// Mood providers for completion flow
final preMoodProvider = StateProvider<int?>((ref) => null);
final postMoodProvider = StateProvider<int?>((ref) => null);

// Favorites provider
final favoriteEntriesProvider = FutureProvider<List<Entry>>((ref) async {
  ref.watch(entriesProvider);
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getFavoriteEntries();
});
