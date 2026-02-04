import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/day_entries_sheet.dart';
import 'widgets/streak_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakDataAsync = ref.watch(streakDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak cards
              streakDataAsync.when(
                data: (streakData) {
                  if (streakData.totalCompletionDays == 0) {
                    return _EmptyStreakCard();
                  }
                  return Column(
                    children: [
                      StreakCard(
                        currentStreak: streakData.currentStreak,
                        longestStreak: streakData.longestStreak,
                      ),
                      const SizedBox(height: 8),
                      _TotalDaysIndicator(
                        totalDays: streakData.totalCompletionDays,
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text('Error loading streak data: $error'),
                ),
              ),
              const SizedBox(height: 24),
              // Calendar section
              Text(
                'Completion History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              CalendarWidget(
                onDaySelected: (date, _) {
                  DayEntriesSheet.show(context, date);
                },
              ),
              const SizedBox(height: 16),
              // Legend
              _CalendarLegend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Start Your Streak',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first sentence to begin tracking your progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalDaysIndicator extends StatelessWidget {
  final int totalDays;

  const _TotalDaysIndicator({required this.totalDays});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$totalDays total ${totalDays == 1 ? 'day' : 'days'} with entries',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: colorScheme.primary,
          label: 'Completed',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: Colors.transparent,
          borderColor: colorScheme.primary,
          label: 'Today',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
