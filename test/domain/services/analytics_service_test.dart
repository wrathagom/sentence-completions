import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sentence_completion/data/models/category.dart';
import 'package:sentence_completion/data/models/entry.dart';
import 'package:sentence_completion/data/repositories/entry_repository.dart';
import 'package:sentence_completion/data/repositories/stem_repository.dart';
import 'package:sentence_completion/domain/services/analytics_service.dart';

class MockEntryRepository extends Mock implements EntryRepository {}

class MockStemRepository extends Mock implements StemRepository {}

void main() {
  late MockEntryRepository mockEntryRepository;
  late MockStemRepository mockStemRepository;
  late AnalyticsService analyticsService;

  final testCategories = [
    const Category(
      id: 'cat1',
      name: 'Self-Awareness',
      emoji: '🧠',
      sortOrder: 0,
    ),
    const Category(
      id: 'cat2',
      name: 'Gratitude',
      emoji: '🙏',
      sortOrder: 1,
    ),
  ];

  final testEntries = [
    Entry(
      id: '1',
      stemId: 'stem1',
      stemText: 'I feel grateful for...',
      completion: 'my family and friends who support me every day',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      categoryId: 'cat1',
    ),
    Entry(
      id: '2',
      stemId: 'stem2',
      stemText: 'Today I learned...',
      completion: 'something new about myself and my capabilities',
      createdAt: DateTime(2024, 1, 14, 9, 0),
      categoryId: 'cat1',
    ),
    Entry(
      id: '3',
      stemId: 'stem3',
      stemText: 'I am thankful for...',
      completion: 'the opportunities that come my way',
      createdAt: DateTime(2024, 2, 1, 8, 0),
      categoryId: 'cat2',
    ),
  ];

  setUp(() {
    mockEntryRepository = MockEntryRepository();
    mockStemRepository = MockStemRepository();
    analyticsService = AnalyticsService(
      entryRepository: mockEntryRepository,
      stemRepository: mockStemRepository,
    );
  });

  group('AnalyticsService', () {
    test('returns empty analytics when no entries exist', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => []);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.totalEntries, 0);
      expect(result.totalWords, 0);
      expect(result.topWords, isEmpty);
      expect(result.categoryDistribution, isEmpty);
    });

    test('calculates correct total entries', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.totalEntries, 3);
    });

    test('calculates word count correctly', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.totalWords, greaterThan(0));
      expect(result.averageWordsPerEntry, greaterThan(0));
    });

    test('extracts word frequencies excluding stop words', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.topWords, isNotEmpty);

      final words = result.topWords.map((w) => w.word).toList();
      expect(words, isNot(contains('the')));
      expect(words, isNot(contains('and')));
      expect(words, isNot(contains('my')));
    });

    test('calculates category distribution', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.categoryDistribution.length, 2);

      final cat1 = result.categoryDistribution
          .firstWhere((c) => c.categoryId == 'cat1');
      expect(cat1.entryCount, 2);
      expect(cat1.percentage, closeTo(66.67, 0.1));

      final cat2 = result.categoryDistribution
          .firstWhere((c) => c.categoryId == 'cat2');
      expect(cat2.entryCount, 1);
      expect(cat2.percentage, closeTo(33.33, 0.1));
    });

    test('calculates entries by month', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.entriesByMonth['2024-01'], 2);
      expect(result.entriesByMonth['2024-02'], 1);
    });

    test('calculates unique stems count', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      expect(result.uniqueStems, 3);
    });

    test('word frequencies are normalized correctly', () async {
      when(() => mockEntryRepository.getAllEntries())
          .thenAnswer((_) async => testEntries);
      when(() => mockStemRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      final result = await analyticsService.getAnalytics();

      for (final word in result.topWords) {
        expect(word.normalizedSize, greaterThanOrEqualTo(0.5));
        expect(word.normalizedSize, lessThanOrEqualTo(1.0));
      }
    });
  });
}
