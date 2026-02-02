import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentence_completion/data/models/entry.dart';
import 'package:sentence_completion/data/models/goal.dart';
import 'package:sentence_completion/data/models/streak_data.dart';
import 'package:sentence_completion/data/repositories/entry_repository.dart';
import 'package:sentence_completion/data/repositories/goal_repository.dart';
import 'package:sentence_completion/domain/services/goal_service.dart';
import 'package:sentence_completion/domain/services/streak_service.dart';

class MockGoalRepository extends Mock implements GoalRepository {}

class MockEntryRepository extends Mock implements EntryRepository {}

class MockStreakService extends Mock implements StreakService {}

class FakeGoal extends Fake implements Goal {}

void main() {
  late GoalService service;
  late MockGoalRepository mockGoalRepository;
  late MockEntryRepository mockEntryRepository;
  late MockStreakService mockStreakService;

  setUpAll(() {
    registerFallbackValue(FakeGoal());
    registerFallbackValue(GoalType.entries);
    registerFallbackValue(GoalPeriod.weekly);
  });

  setUp(() {
    mockGoalRepository = MockGoalRepository();
    mockEntryRepository = MockEntryRepository();
    mockStreakService = MockStreakService();
    service = GoalService(
      goalRepository: mockGoalRepository,
      entryRepository: mockEntryRepository,
      streakService: mockStreakService,
    );
  });

  group('GoalService', () {
    group('getActiveGoalsWithProgress', () {
      test('returns empty list when no active goals', () async {
        when(() => mockGoalRepository.getActiveGoals())
            .thenAnswer((_) async => []);

        final result = await service.getActiveGoalsWithProgress();

        expect(result, isEmpty);
      });

      test('calculates entries progress for weekly goal', () async {
        final now = DateTime.now();
        final goal = Goal(
          id: 'goal-1',
          type: GoalType.entries,
          target: 5,
          period: GoalPeriod.weekly,
          createdAt: now.subtract(const Duration(days: 1)),
          isActive: true,
        );

        // Create 3 entries all on the same day (today) to ensure they're in the same week
        final entries = List.generate(
          3,
          (i) => Entry(
            id: 'entry-$i',
            stemId: 'stem-$i',
            stemText: 'Stem $i',
            completion: 'Completion $i',
            createdAt: now,
            categoryId: 'cat-1',
          ),
        );

        when(() => mockGoalRepository.getActiveGoals())
            .thenAnswer((_) async => [goal]);
        when(() => mockEntryRepository.getAllEntries())
            .thenAnswer((_) async => entries);

        final result = await service.getActiveGoalsWithProgress();

        expect(result.length, 1);
        expect(result.first.goal, goal);
        expect(result.first.currentProgress, 3);
        expect(result.first.isCompleted, false);
      });

      test('calculates streak progress for streak goal', () async {
        final now = DateTime.now();
        final goal = Goal(
          id: 'goal-1',
          type: GoalType.streak,
          target: 7,
          period: GoalPeriod.daily,
          createdAt: now.subtract(const Duration(days: 1)),
          isActive: true,
        );

        final streakData = StreakData(
          currentStreak: 5,
          longestStreak: 10,
          totalCompletionDays: 20,
        );

        when(() => mockGoalRepository.getActiveGoals())
            .thenAnswer((_) async => [goal]);
        when(() => mockStreakService.calculateStreakData())
            .thenAnswer((_) async => streakData);

        final result = await service.getActiveGoalsWithProgress();

        expect(result.length, 1);
        expect(result.first.goal, goal);
        expect(result.first.currentProgress, 5);
        expect(result.first.isCompleted, false);
      });

      test('marks goal as completed when target reached', () async {
        final now = DateTime.now();
        final goal = Goal(
          id: 'goal-1',
          type: GoalType.entries,
          target: 3,
          period: GoalPeriod.daily,
          createdAt: now,
          isActive: true,
        );

        final entries = List.generate(
          5,
          (i) => Entry(
            id: 'entry-$i',
            stemId: 'stem-$i',
            stemText: 'Stem $i',
            completion: 'Completion $i',
            createdAt: now,
            categoryId: 'cat-1',
          ),
        );

        when(() => mockGoalRepository.getActiveGoals())
            .thenAnswer((_) async => [goal]);
        when(() => mockEntryRepository.getAllEntries())
            .thenAnswer((_) async => entries);

        final result = await service.getActiveGoalsWithProgress();

        expect(result.first.isCompleted, true);
        expect(result.first.progressPercent, 1.0);
      });
    });

    group('createGoal', () {
      test('delegates to repository', () async {
        final goal = Goal(
          id: 'goal-1',
          type: GoalType.entries,
          target: 5,
          period: GoalPeriod.weekly,
          createdAt: DateTime.now(),
          isActive: true,
        );

        when(() => mockGoalRepository.createGoal(
              type: any(named: 'type'),
              target: any(named: 'target'),
              period: any(named: 'period'),
            )).thenAnswer((_) async => goal);

        final result = await service.createGoal(
          type: GoalType.entries,
          target: 5,
          period: GoalPeriod.weekly,
        );

        expect(result, goal);
        verify(() => mockGoalRepository.createGoal(
              type: GoalType.entries,
              target: 5,
              period: GoalPeriod.weekly,
            )).called(1);
      });
    });

    group('deleteGoal', () {
      test('delegates to repository', () async {
        when(() => mockGoalRepository.deleteGoal(any()))
            .thenAnswer((_) async {});

        await service.deleteGoal('goal-1');

        verify(() => mockGoalRepository.deleteGoal('goal-1')).called(1);
      });
    });

    group('getPeriodLabel', () {
      test('returns correct labels', () {
        expect(service.getPeriodLabel(GoalPeriod.daily), 'Today');
        expect(service.getPeriodLabel(GoalPeriod.weekly), 'This week');
        expect(service.getPeriodLabel(GoalPeriod.monthly), 'This month');
      });
    });
  });

  group('GoalWithProgress', () {
    test('progressPercent returns correct value', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 10,
        period: GoalPeriod.weekly,
        createdAt: DateTime.now(),
      );

      final progress = GoalWithProgress(goal: goal, currentProgress: 5);
      expect(progress.progressPercent, 0.5);
    });

    test('progressPercent clamps to 1.0', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 5,
        period: GoalPeriod.weekly,
        createdAt: DateTime.now(),
      );

      final progress = GoalWithProgress(goal: goal, currentProgress: 10);
      expect(progress.progressPercent, 1.0);
    });

    test('remaining returns correct value', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 10,
        period: GoalPeriod.weekly,
        createdAt: DateTime.now(),
      );

      final progress = GoalWithProgress(goal: goal, currentProgress: 3);
      expect(progress.remaining, 7);
    });

    test('remaining clamps to 0', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 5,
        period: GoalPeriod.weekly,
        createdAt: DateTime.now(),
      );

      final progress = GoalWithProgress(goal: goal, currentProgress: 10);
      expect(progress.remaining, 0);
    });
  });

  group('Goal model', () {
    test('displayDescription for entries goal', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 5,
        period: GoalPeriod.weekly,
        createdAt: DateTime.now(),
      );

      expect(goal.displayDescription, 'Complete 5 entries weekly');
    });

    test('displayDescription for streak goal', () {
      final goal = Goal(
        id: 'goal-1',
        type: GoalType.streak,
        target: 7,
        period: GoalPeriod.daily,
        createdAt: DateTime.now(),
      );

      expect(goal.displayDescription, 'Maintain a 7 day streak');
    });

    test('toMap and fromMap round-trip', () {
      final original = Goal(
        id: 'goal-1',
        type: GoalType.entries,
        target: 5,
        period: GoalPeriod.monthly,
        createdAt: DateTime(2024, 6, 15, 10, 30),
        isActive: true,
      );

      final map = original.toMap();
      final restored = Goal.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.target, original.target);
      expect(restored.period, original.period);
      expect(restored.isActive, original.isActive);
    });
  });

  group('GoalPeriod', () {
    test('fromValue returns correct period', () {
      expect(GoalPeriod.fromValue('daily'), GoalPeriod.daily);
      expect(GoalPeriod.fromValue('weekly'), GoalPeriod.weekly);
      expect(GoalPeriod.fromValue('monthly'), GoalPeriod.monthly);
    });

    test('fromValue returns weekly for unknown value', () {
      expect(GoalPeriod.fromValue('unknown'), GoalPeriod.weekly);
    });
  });

  group('GoalType', () {
    test('fromValue returns correct type', () {
      expect(GoalType.fromValue('entries'), GoalType.entries);
      expect(GoalType.fromValue('streak'), GoalType.streak);
    });

    test('fromValue returns entries for unknown value', () {
      expect(GoalType.fromValue('unknown'), GoalType.entries);
    });
  });
}
