import '../../data/datasources/local/resurfacing_local_datasource.dart';
import '../../data/models/entry.dart';
import '../../data/repositories/entry_repository.dart';

class ResurfacingEntry {
  final ResurfacingSchedule schedule;
  final Entry originalEntry;
  final int monthsAgo;

  const ResurfacingEntry({
    required this.schedule,
    required this.originalEntry,
    required this.monthsAgo,
  });
}

class ResurfacingService {
  final EntryRepository _entryRepository;

  ResurfacingService({required EntryRepository entryRepository})
      : _entryRepository = entryRepository;

  Future<List<ResurfacingEntry>> getPendingResurfacing() async {
    final schedules = await _entryRepository.getPendingResurfacing();
    final results = <ResurfacingEntry>[];

    for (final schedule in schedules) {
      final entry = await _entryRepository.getEntryById(schedule.entryId);
      if (entry != null) {
        final monthsAgo = _calculateMonthsAgo(entry.createdAt);
        results.add(ResurfacingEntry(
          schedule: schedule,
          originalEntry: entry,
          monthsAgo: monthsAgo,
        ));
      }
    }

    return results;
  }

  int _calculateMonthsAgo(DateTime date) {
    final now = DateTime.now();
    return (now.year - date.year) * 12 + (now.month - date.month);
  }

  Future<Entry> completeResurfacing({
    required ResurfacingEntry resurfacing,
    required String completion,
  }) async {
    final entry = await _entryRepository.createEntry(
      stemId: resurfacing.originalEntry.stemId,
      stemText: resurfacing.originalEntry.stemText,
      completion: completion,
      categoryId: resurfacing.originalEntry.categoryId,
      parentEntryId: resurfacing.originalEntry.id,
      resurfaceMonth: resurfacing.monthsAgo,
    );

    await _entryRepository.markResurfacingCompleted(resurfacing.schedule.id);

    return entry;
  }

  Future<List<Entry>> getEntryHistory(String entryId) async {
    final entry = await _entryRepository.getEntryById(entryId);
    if (entry == null) return [];

    // Get the root entry (if this is a resurfaced entry)
    final rootId = entry.parentEntryId ?? entry.id;
    final rootEntry = entry.parentEntryId != null
        ? await _entryRepository.getEntryById(rootId)
        : entry;

    if (rootEntry == null) return [entry];

    // Get all resurfaced entries
    final resurfaced = await _entryRepository.getResurfacedEntries(rootId);

    // Sort by date
    final all = [rootEntry, ...resurfaced];
    all.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return all;
  }
}
