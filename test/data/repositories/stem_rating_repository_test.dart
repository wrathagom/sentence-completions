import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentence_completion/data/datasources/local/stem_rating_datasource.dart';
import 'package:sentence_completion/data/models/stem_rating.dart';
import 'package:sentence_completion/data/repositories/stem_rating_repository.dart';
import 'package:uuid/uuid.dart';

class MockStemRatingDatasource extends Mock implements StemRatingDatasource {}

class MockUuid extends Mock implements Uuid {}

class FakeStemRating extends Fake implements StemRating {}

void main() {
  late StemRatingRepository repository;
  late MockStemRatingDatasource mockDatasource;
  late MockUuid mockUuid;

  setUpAll(() {
    registerFallbackValue(FakeStemRating());
  });

  setUp(() {
    mockDatasource = MockStemRatingDatasource();
    mockUuid = MockUuid();
    repository = StemRatingRepository(
      datasource: mockDatasource,
      uuid: mockUuid,
    );
  });

  group('StemRatingRepository', () {
    group('rateStem', () {
      test('creates new rating when no existing rating', () async {
        const stemId = 'stem-1';
        const entryId = 'entry-1';
        const ratingValue = StemRatingValue.positive;
        const generatedId = 'generated-uuid';

        when(() => mockDatasource.getRatingByStemId(stemId))
            .thenAnswer((_) async => null);
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(() => mockDatasource.insertRating(any()))
            .thenAnswer((_) async {});

        final result = await repository.rateStem(
          stemId: stemId,
          rating: ratingValue,
          entryId: entryId,
        );

        expect(result.id, generatedId);
        expect(result.stemId, stemId);
        expect(result.rating, ratingValue);
        expect(result.entryId, entryId);

        verify(() => mockDatasource.getRatingByStemId(stemId)).called(1);
        verify(() => mockDatasource.insertRating(any())).called(1);
        verifyNever(() => mockDatasource.updateRating(any()));
      });

      test('updates existing rating', () async {
        const stemId = 'stem-1';
        const entryId = 'entry-1';
        const ratingValue = StemRatingValue.negative;

        final existingRating = StemRating(
          id: 'existing-id',
          stemId: stemId,
          rating: StemRatingValue.positive,
          entryId: entryId,
          ratedAt: DateTime(2024, 1, 1),
        );

        when(() => mockDatasource.getRatingByStemId(stemId))
            .thenAnswer((_) async => existingRating);
        when(() => mockDatasource.updateRating(any()))
            .thenAnswer((_) async {});

        final result = await repository.rateStem(
          stemId: stemId,
          rating: ratingValue,
          entryId: entryId,
        );

        expect(result.id, existingRating.id);
        expect(result.stemId, stemId);
        expect(result.rating, ratingValue);
        expect(result.entryId, entryId);

        verify(() => mockDatasource.getRatingByStemId(stemId)).called(1);
        verify(() => mockDatasource.updateRating(any())).called(1);
        verifyNever(() => mockDatasource.insertRating(any()));
      });
    });

    group('getRatingForStem', () {
      test('returns rating when exists', () async {
        const stemId = 'stem-1';
        final rating = StemRating(
          id: 'rating-1',
          stemId: stemId,
          rating: StemRatingValue.neutral,
          ratedAt: DateTime.now(),
        );

        when(() => mockDatasource.getRatingByStemId(stemId))
            .thenAnswer((_) async => rating);

        final result = await repository.getRatingForStem(stemId);

        expect(result, rating);
        verify(() => mockDatasource.getRatingByStemId(stemId)).called(1);
      });

      test('returns null when no rating exists', () async {
        const stemId = 'stem-1';

        when(() => mockDatasource.getRatingByStemId(stemId))
            .thenAnswer((_) async => null);

        final result = await repository.getRatingForStem(stemId);

        expect(result, isNull);
      });
    });

    group('getRatingForEntry', () {
      test('returns rating when exists', () async {
        const entryId = 'entry-1';
        final rating = StemRating(
          id: 'rating-1',
          stemId: 'stem-1',
          rating: StemRatingValue.positive,
          entryId: entryId,
          ratedAt: DateTime.now(),
        );

        when(() => mockDatasource.getRatingByEntryId(entryId))
            .thenAnswer((_) async => rating);

        final result = await repository.getRatingForEntry(entryId);

        expect(result, rating);
        verify(() => mockDatasource.getRatingByEntryId(entryId)).called(1);
      });
    });

    group('getAllRatings', () {
      test('returns all ratings', () async {
        final ratings = [
          StemRating(
            id: 'rating-1',
            stemId: 'stem-1',
            rating: StemRatingValue.positive,
            ratedAt: DateTime.now(),
          ),
          StemRating(
            id: 'rating-2',
            stemId: 'stem-2',
            rating: StemRatingValue.negative,
            ratedAt: DateTime.now(),
          ),
        ];

        when(() => mockDatasource.getAllRatings())
            .thenAnswer((_) async => ratings);

        final result = await repository.getAllRatings();

        expect(result, ratings);
        expect(result.length, 2);
      });
    });

    group('getPositiveRatings', () {
      test('returns only positive ratings', () async {
        final positiveRatings = [
          StemRating(
            id: 'rating-1',
            stemId: 'stem-1',
            rating: StemRatingValue.positive,
            ratedAt: DateTime.now(),
          ),
        ];

        when(() => mockDatasource.getRatingsByValue(StemRatingValue.positive))
            .thenAnswer((_) async => positiveRatings);

        final result = await repository.getPositiveRatings();

        expect(result, positiveRatings);
        expect(result.every((r) => r.rating == StemRatingValue.positive), true);
      });
    });

    group('getNegativeRatings', () {
      test('returns only negative ratings', () async {
        final negativeRatings = [
          StemRating(
            id: 'rating-1',
            stemId: 'stem-1',
            rating: StemRatingValue.negative,
            ratedAt: DateTime.now(),
          ),
        ];

        when(() => mockDatasource.getRatingsByValue(StemRatingValue.negative))
            .thenAnswer((_) async => negativeRatings);

        final result = await repository.getNegativeRatings();

        expect(result, negativeRatings);
        expect(result.every((r) => r.rating == StemRatingValue.negative), true);
      });
    });

    group('deleteRating', () {
      test('deletes rating by id', () async {
        const ratingId = 'rating-1';

        when(() => mockDatasource.deleteRating(ratingId))
            .thenAnswer((_) async {});

        await repository.deleteRating(ratingId);

        verify(() => mockDatasource.deleteRating(ratingId)).called(1);
      });
    });
  });

  group('StemRatingValue', () {
    test('fromValue returns correct enum values', () {
      expect(StemRatingValue.fromValue(-1), StemRatingValue.negative);
      expect(StemRatingValue.fromValue(0), StemRatingValue.neutral);
      expect(StemRatingValue.fromValue(1), StemRatingValue.positive);
    });

    test('fromValue returns null for null input', () {
      expect(StemRatingValue.fromValue(null), isNull);
    });

    test('fromValue returns neutral for unknown values', () {
      expect(StemRatingValue.fromValue(99), StemRatingValue.neutral);
    });

    test('enum has correct values', () {
      expect(StemRatingValue.negative.value, -1);
      expect(StemRatingValue.neutral.value, 0);
      expect(StemRatingValue.positive.value, 1);
    });

    test('enum has correct labels', () {
      expect(StemRatingValue.negative.label, 'Not for me');
      expect(StemRatingValue.neutral.label, 'Neutral');
      expect(StemRatingValue.positive.label, 'Resonated');
    });

    test('enum has correct emojis', () {
      expect(StemRatingValue.negative.emoji, '👎');
      expect(StemRatingValue.neutral.emoji, '😐');
      expect(StemRatingValue.positive.emoji, '👍');
    });
  });
}
