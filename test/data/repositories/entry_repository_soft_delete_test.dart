import 'package:flutter_test/flutter_test.dart';
import 'package:sentence_completion/data/models/deleted_entry.dart';

void main() {
  group('DeletedEntry', () {
    test('toMap and fromMap round-trip', () {
      final original = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime(2024, 6, 15, 10, 30),
        deletedAt: DateTime(2024, 7, 1, 14, 0),
        categoryId: 'cat-1',
        parentEntryId: null,
        resurfaceMonth: 3,
        suggestedStems: ['stem1', 'stem2'],
        preMood: 3,
        postMood: 4,
        isFavorite: true,
      );

      final map = original.toMap();
      final restored = DeletedEntry.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.originalId, original.originalId);
      expect(restored.stemId, original.stemId);
      expect(restored.stemText, original.stemText);
      expect(restored.completion, original.completion);
      expect(restored.categoryId, original.categoryId);
      expect(restored.parentEntryId, original.parentEntryId);
      expect(restored.resurfaceMonth, original.resurfaceMonth);
      expect(restored.suggestedStems, original.suggestedStems);
      expect(restored.preMood, original.preMood);
      expect(restored.postMood, original.postMood);
      expect(restored.isFavorite, original.isFavorite);
    });

    test('canRestore returns true within retention period', () {
      final entry = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        deletedAt: DateTime.now().subtract(const Duration(days: 1)),
        categoryId: 'cat-1',
      );

      expect(entry.canRestore, isTrue);
    });

    test('canRestore returns false after retention period', () {
      final entry = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        deletedAt: DateTime.now().subtract(const Duration(days: 35)),
        categoryId: 'cat-1',
      );

      expect(entry.canRestore, isFalse);
    });

    test('daysRemaining calculates correctly', () {
      final entry = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime.now(),
        deletedAt: DateTime.now().subtract(const Duration(days: 10)),
        categoryId: 'cat-1',
      );

      // 30 days retention - 10 days elapsed = 19-20 days remaining (depending on time of day)
      expect(entry.daysRemaining, inInclusiveRange(19, 20));
    });

    test('daysRemaining returns 0 when expired', () {
      final entry = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime.now(),
        deletedAt: DateTime.now().subtract(const Duration(days: 40)),
        categoryId: 'cat-1',
      );

      expect(entry.daysRemaining, 0);
    });

    test('copyWith creates new instance with updated values', () {
      final original = DeletedEntry(
        id: 'deleted-1',
        originalId: 'entry-1',
        stemId: 'stem-1',
        stemText: 'When I feel...',
        completion: 'happy',
        createdAt: DateTime(2024, 6, 15),
        deletedAt: DateTime(2024, 7, 1),
        categoryId: 'cat-1',
        isFavorite: false,
      );

      final updated = original.copyWith(
        stemText: 'When I think...',
        isFavorite: true,
      );

      expect(updated.id, original.id);
      expect(updated.stemText, 'When I think...');
      expect(updated.isFavorite, true);
      expect(updated.completion, original.completion);
    });

    test('retentionDays is 30', () {
      expect(DeletedEntry.retentionDays, 30);
    });
  });
}
