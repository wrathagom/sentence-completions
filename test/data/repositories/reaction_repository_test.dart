import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentence_completion/data/datasources/local/reaction_datasource.dart';
import 'package:sentence_completion/data/models/entry_reaction.dart';
import 'package:sentence_completion/data/repositories/reaction_repository.dart';
import 'package:uuid/uuid.dart';

class MockReactionDatasource extends Mock implements ReactionDatasource {}

class MockUuid extends Mock implements Uuid {}

class FakeEntryReaction extends Fake implements EntryReaction {}

void main() {
  late ReactionRepository repository;
  late MockReactionDatasource mockDatasource;
  late MockUuid mockUuid;

  setUpAll(() {
    registerFallbackValue(FakeEntryReaction());
  });

  setUp(() {
    mockDatasource = MockReactionDatasource();
    mockUuid = MockUuid();
    repository = ReactionRepository(
      datasource: mockDatasource,
      uuid: mockUuid,
    );
  });

  group('ReactionRepository', () {
    group('addReaction', () {
      test('creates and inserts new reaction', () async {
        const entryId = 'entry-1';
        const reactionType = ReactionType.insightful;
        const note = 'Test note';
        const generatedId = 'generated-uuid';

        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(() => mockDatasource.insertReaction(any()))
            .thenAnswer((_) async {});

        final result = await repository.addReaction(
          entryId: entryId,
          reactionType: reactionType,
          note: note,
        );

        expect(result.id, generatedId);
        expect(result.entryId, entryId);
        expect(result.reactionType, reactionType);
        expect(result.note, note);

        verify(() => mockDatasource.insertReaction(any())).called(1);
      });

      test('creates reaction without note', () async {
        const entryId = 'entry-1';
        const reactionType = ReactionType.proud;
        const generatedId = 'generated-uuid';

        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(() => mockDatasource.insertReaction(any()))
            .thenAnswer((_) async {});

        final result = await repository.addReaction(
          entryId: entryId,
          reactionType: reactionType,
        );

        expect(result.note, isNull);
        verify(() => mockDatasource.insertReaction(any())).called(1);
      });
    });

    group('getReactionsForEntry', () {
      test('returns reactions for entry', () async {
        const entryId = 'entry-1';
        final reactions = [
          EntryReaction(
            id: 'reaction-1',
            entryId: entryId,
            reactionType: ReactionType.insightful,
            createdAt: DateTime.now(),
          ),
          EntryReaction(
            id: 'reaction-2',
            entryId: entryId,
            reactionType: ReactionType.proud,
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockDatasource.getReactionsForEntry(entryId))
            .thenAnswer((_) async => reactions);

        final result = await repository.getReactionsForEntry(entryId);

        expect(result, reactions);
        expect(result.length, 2);
      });
    });

    group('deleteReaction', () {
      test('deletes reaction by id', () async {
        const reactionId = 'reaction-1';

        when(() => mockDatasource.deleteReaction(reactionId))
            .thenAnswer((_) async {});

        await repository.deleteReaction(reactionId);

        verify(() => mockDatasource.deleteReaction(reactionId)).called(1);
      });
    });

    group('toggleReaction', () {
      test('adds reaction when not present', () async {
        const entryId = 'entry-1';
        const reactionType = ReactionType.growth;
        const generatedId = 'generated-uuid';

        when(() => mockDatasource.getReactionsForEntry(entryId))
            .thenAnswer((_) async => []);
        when(() => mockUuid.v4()).thenReturn(generatedId);
        when(() => mockDatasource.insertReaction(any()))
            .thenAnswer((_) async {});

        final result = await repository.toggleReaction(
          entryId: entryId,
          reactionType: reactionType,
        );

        expect(result.id, generatedId);
        expect(result.reactionType, reactionType);
        verify(() => mockDatasource.insertReaction(any())).called(1);
      });

      test('removes reaction when already present', () async {
        const entryId = 'entry-1';
        const reactionType = ReactionType.growth;
        final existingReaction = EntryReaction(
          id: 'existing-id',
          entryId: entryId,
          reactionType: reactionType,
          createdAt: DateTime.now(),
        );

        when(() => mockDatasource.getReactionsForEntry(entryId))
            .thenAnswer((_) async => [existingReaction]);
        when(() => mockDatasource.deleteReaction(existingReaction.id))
            .thenAnswer((_) async {});

        final result = await repository.toggleReaction(
          entryId: entryId,
          reactionType: reactionType,
        );

        expect(result.id, ''); // Empty id indicates removal
        verify(() => mockDatasource.deleteReaction(existingReaction.id)).called(1);
        verifyNever(() => mockDatasource.insertReaction(any()));
      });
    });
  });

  group('ReactionType', () {
    test('fromValue returns correct type', () {
      expect(ReactionType.fromValue('insightful'), ReactionType.insightful);
      expect(ReactionType.fromValue('proud'), ReactionType.proud);
      expect(ReactionType.fromValue('growth'), ReactionType.growth);
      expect(ReactionType.fromValue('grateful'), ReactionType.grateful);
      expect(ReactionType.fromValue('challenged'), ReactionType.challenged);
      expect(ReactionType.fromValue('peaceful'), ReactionType.peaceful);
    });

    test('fromValue returns insightful for unknown value', () {
      expect(ReactionType.fromValue('unknown'), ReactionType.insightful);
    });

    test('enum has correct emojis', () {
      expect(ReactionType.insightful.emoji, '💡');
      expect(ReactionType.proud.emoji, '🌟');
      expect(ReactionType.growth.emoji, '🌱');
      expect(ReactionType.grateful.emoji, '🙏');
      expect(ReactionType.challenged.emoji, '💪');
      expect(ReactionType.peaceful.emoji, '🕊️');
    });

    test('displayLabel returns emoji and label', () {
      expect(ReactionType.insightful.displayLabel, '💡 Insightful');
      expect(ReactionType.proud.displayLabel, '🌟 Proud');
    });
  });

  group('EntryReaction', () {
    test('toMap and fromMap round-trip', () {
      final original = EntryReaction(
        id: 'reaction-1',
        entryId: 'entry-1',
        reactionType: ReactionType.grateful,
        note: 'Test note',
        createdAt: DateTime(2024, 6, 15, 10, 30),
      );

      final map = original.toMap();
      final restored = EntryReaction.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.entryId, original.entryId);
      expect(restored.reactionType, original.reactionType);
      expect(restored.note, original.note);
    });

    test('copyWith creates new instance with updated values', () {
      final original = EntryReaction(
        id: 'reaction-1',
        entryId: 'entry-1',
        reactionType: ReactionType.proud,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        reactionType: ReactionType.growth,
        note: 'New note',
      );

      expect(updated.id, original.id);
      expect(updated.entryId, original.entryId);
      expect(updated.reactionType, ReactionType.growth);
      expect(updated.note, 'New note');
    });
  });
}
