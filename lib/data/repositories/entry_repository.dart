import 'package:uuid/uuid.dart';

import '../datasources/local/deleted_entry_datasource.dart';
import '../datasources/local/entry_local_datasource.dart';
import '../datasources/local/resurfacing_local_datasource.dart';
import '../models/deleted_entry.dart';
import '../models/entry.dart';

class EntryRepository {
  final EntryLocalDatasource _entryDatasource;
  final ResurfacingLocalDatasource _resurfacingDatasource;
  final DeletedEntryDatasource _deletedEntryDatasource;
  final Uuid _uuid;

  EntryRepository({
    required EntryLocalDatasource entryDatasource,
    required ResurfacingLocalDatasource resurfacingDatasource,
    DeletedEntryDatasource? deletedEntryDatasource,
    Uuid? uuid,
  })  : _entryDatasource = entryDatasource,
        _resurfacingDatasource = resurfacingDatasource,
        _deletedEntryDatasource = deletedEntryDatasource ?? DeletedEntryDatasource(),
        _uuid = uuid ?? const Uuid();

  Future<Entry> createEntry({
    required String stemId,
    required String stemText,
    required String completion,
    required String categoryId,
    String? parentEntryId,
    int? resurfaceMonth,
    int? preMoodValue,
    int? postMoodValue,
    DateTime? createdAt,
    bool scheduleResurfacing = true,
  }) async {
    final entry = Entry(
      id: _uuid.v4(),
      stemId: stemId,
      stemText: stemText,
      completion: completion,
      createdAt: createdAt ?? DateTime.now(),
      categoryId: categoryId,
      parentEntryId: parentEntryId,
      resurfaceMonth: resurfaceMonth,
      preMoodValue: preMoodValue,
      postMoodValue: postMoodValue,
    );

    await _entryDatasource.insertEntry(entry);

    // Schedule resurfacing for new entries (not resurfaced entries)
    // Skip scheduling if explicitly disabled (e.g., for imports)
    if (scheduleResurfacing && parentEntryId == null) {
      await _scheduleResurfacing(entry);
    }

    return entry;
  }

  Future<void> _scheduleResurfacing(Entry entry) async {
    final now = DateTime.now();

    // Schedule 3-month resurfacing
    final threeMonths = DateTime(now.year, now.month + 3, now.day);
    await _resurfacingDatasource.scheduleResurfacing(
      ResurfacingSchedule(
        id: _uuid.v4(),
        entryId: entry.id,
        scheduledDate: threeMonths,
      ),
    );

    // Schedule 6-month resurfacing
    final sixMonths = DateTime(now.year, now.month + 6, now.day);
    await _resurfacingDatasource.scheduleResurfacing(
      ResurfacingSchedule(
        id: _uuid.v4(),
        entryId: entry.id,
        scheduledDate: sixMonths,
      ),
    );
  }

  Future<void> updateEntry(Entry entry) async {
    await _entryDatasource.updateEntry(entry);
  }

  Future<void> updateEntrySuggestions(String entryId, List<String> suggestions) async {
    final entry = await getEntryById(entryId);
    if (entry != null) {
      await _entryDatasource.updateEntry(entry.copyWith(suggestedStems: suggestions));
    }
  }

  Future<void> deleteEntry(String id) async {
    await _resurfacingDatasource.deleteScheduleForEntry(id);
    await _entryDatasource.deleteEntry(id);
  }

  Future<Entry?> getEntryById(String id) {
    return _entryDatasource.getEntryById(id);
  }

  Future<List<Entry>> getAllEntries() {
    return _entryDatasource.getAllEntries();
  }

  Future<List<Entry>> getEntriesByCategory(String categoryId) {
    return _entryDatasource.getEntriesByCategory(categoryId);
  }

  Future<List<Entry>> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entryDatasource.getEntriesForDateRange(start, end);
  }

  Future<Entry?> getTodayEntry() {
    return _entryDatasource.getEntryForDate(DateTime.now());
  }

  Future<bool> hasCompletedToday() {
    return _entryDatasource.hasEntryForToday();
  }

  Future<int> getTodayEntryCount() {
    return _entryDatasource.getEntryCountForDate(DateTime.now());
  }

  Future<List<Entry>> searchEntries(String query) {
    return _entryDatasource.searchEntries(query);
  }

  Future<List<Entry>> getEntriesByStemId(String stemId) {
    return _entryDatasource.getEntriesByStemId(stemId);
  }

  Future<List<Entry>> getResurfacedEntries(String parentEntryId) {
    return _entryDatasource.getResurfacedEntries(parentEntryId);
  }

  Future<List<ResurfacingSchedule>> getPendingResurfacing() {
    return _resurfacingDatasource.getPendingResurfacing();
  }

  Future<void> markResurfacingCompleted(String scheduleId) {
    return _resurfacingDatasource.markCompleted(scheduleId);
  }

  Future<List<DateTime>> getCompletionDates() {
    return _entryDatasource.getCompletionDates();
  }

  Future<List<Entry>> getAllEntriesForDate(DateTime date) {
    return _entryDatasource.getAllEntriesForDate(date);
  }

  Future<void> toggleFavorite(String id) {
    return _entryDatasource.toggleFavorite(id);
  }

  Future<List<Entry>> getFavoriteEntries() {
    return _entryDatasource.getFavoriteEntries();
  }

  /// Soft delete an entry (can be restored later)
  Future<DeletedEntry?> softDeleteEntry(String id) async {
    await _resurfacingDatasource.deleteScheduleForEntry(id);
    return _entryDatasource.softDeleteEntry(id);
  }

  /// Restore a soft-deleted entry
  Future<Entry?> restoreEntry(String deletedEntryId) async {
    final entry = await _entryDatasource.restoreEntry(deletedEntryId);
    if (entry != null) {
      // Re-schedule resurfacing for restored entries (if not already resurfaced)
      if (entry.parentEntryId == null) {
        await _scheduleResurfacing(entry);
      }
    }
    return entry;
  }

  /// Get all soft-deleted entries
  Future<List<DeletedEntry>> getDeletedEntries() {
    return _deletedEntryDatasource.getDeletedEntries();
  }

  /// Get count of deleted entries
  Future<int> getDeletedEntryCount() {
    return _deletedEntryDatasource.getDeletedEntryCount();
  }

  /// Permanently delete a soft-deleted entry
  Future<void> permanentlyDeleteEntry(String deletedEntryId) {
    return _deletedEntryDatasource.permanentlyDeleteEntry(deletedEntryId);
  }

  /// Clear all expired deleted entries
  Future<int> clearExpiredDeletedEntries() {
    return _deletedEntryDatasource.clearExpiredEntries();
  }
}
