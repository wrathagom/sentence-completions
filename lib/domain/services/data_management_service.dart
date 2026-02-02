import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/settings_repository.dart';

class DataManagementService {
  final SettingsRepository _settingsRepository;

  DataManagementService({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  /// Delete all user data and reset to initial state
  /// This will:
  /// - Delete all entries
  /// - Delete all deleted entries (soft-deleted)
  /// - Delete all resurfacing schedules
  /// - Delete all saved stems
  /// - Delete all goals and goal progress
  /// - Delete all stem ratings
  /// - Delete all entry reactions
  /// - Reset onboarding status
  Future<void> deleteAllData() async {
    final db = await DatabaseHelper.database;

    // Delete all data from tables in proper order (respecting foreign keys)
    await db.transaction((txn) async {
      // Delete entry-related data first
      await txn.delete('entry_reactions');
      await txn.delete('resurfacing_schedule');
      await txn.delete('deleted_entries');
      await txn.delete('entries');

      // Delete goal-related data
      await txn.delete('goal_progress');
      await txn.delete('goals');

      // Delete other user data
      await txn.delete('saved_stems');
      await txn.delete('stem_ratings');
    });

    // Reset settings to mark onboarding as not completed
    await _settingsRepository.setOnboardingCompleted(false);
  }

  /// Get data statistics for display purposes
  Future<DataStats> getDataStats() async {
    final db = await DatabaseHelper.database;

    final entryCount = await _getTableCount(db, 'entries');
    final deletedEntryCount = await _getTableCount(db, 'deleted_entries');
    final goalCount = await _getTableCount(db, 'goals');
    final savedStemCount = await _getTableCount(db, 'saved_stems');

    return DataStats(
      entryCount: entryCount,
      deletedEntryCount: deletedEntryCount,
      goalCount: goalCount,
      savedStemCount: savedStemCount,
    );
  }

  Future<int> _getTableCount(dynamic db, String tableName) async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int;
  }
}

class DataStats {
  final int entryCount;
  final int deletedEntryCount;
  final int goalCount;
  final int savedStemCount;

  const DataStats({
    required this.entryCount,
    required this.deletedEntryCount,
    required this.goalCount,
    required this.savedStemCount,
  });

  int get totalItems => entryCount + deletedEntryCount + goalCount + savedStemCount;
}
