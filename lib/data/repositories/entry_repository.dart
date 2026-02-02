import 'package:uuid/uuid.dart';

import '../datasources/local/entry_local_datasource.dart';
import '../datasources/local/resurfacing_local_datasource.dart';
import '../models/entry.dart';

class EntryRepository {
  final EntryLocalDatasource _entryDatasource;
  final ResurfacingLocalDatasource _resurfacingDatasource;
  final Uuid _uuid;

  EntryRepository({
    required EntryLocalDatasource entryDatasource,
    required ResurfacingLocalDatasource resurfacingDatasource,
    Uuid? uuid,
  })  : _entryDatasource = entryDatasource,
        _resurfacingDatasource = resurfacingDatasource,
        _uuid = uuid ?? const Uuid();

  Future<Entry> createEntry({
    required String stemId,
    required String stemText,
    required String completion,
    required String categoryId,
    String? parentEntryId,
    int? resurfaceMonth,
  }) async {
    final entry = Entry(
      id: _uuid.v4(),
      stemId: stemId,
      stemText: stemText,
      completion: completion,
      createdAt: DateTime.now(),
      categoryId: categoryId,
      parentEntryId: parentEntryId,
      resurfaceMonth: resurfaceMonth,
    );

    await _entryDatasource.insertEntry(entry);

    // Schedule resurfacing for new entries (not resurfaced entries)
    if (parentEntryId == null) {
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
}
