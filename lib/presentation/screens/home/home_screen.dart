import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/goal_progress_card.dart';
import '../../widgets/responsive_scaffold.dart';
import '../stats/widgets/calendar_widget.dart';
import '../stats/widgets/day_entries_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddAnotherOptions(BuildContext context, WidgetRef ref) {
    final savedStems = ref.read(savedStemsProvider);
    final hasSavedStems = savedStems.valueOrNull?.isNotEmpty ?? false;
    final savedStemCount = savedStems.valueOrNull?.length ?? 0;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Another Entry',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/completion');
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Surprise Me'),
              ),
              if (hasSavedStems) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/saved-stems');
                  },
                  icon: const Icon(Icons.bookmark),
                  label: Text('Continue ($savedStemCount saved)'),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/category-selection');
                },
                icon: const Icon(Icons.category),
                label: const Text('Choose Category'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedToday = ref.watch(hasCompletedTodayProvider);
    final todayEntry = ref.watch(todayEntryProvider);
    final todayEntryCount = ref.watch(todayEntryCountProvider);
    final pendingResurfacing = ref.watch(pendingResurfacingProvider);
    final streakData = ref.watch(streakDataProvider);
    final goalsWithProgress = ref.watch(activeGoalsWithProgressProvider);
    // Pre-fetch saved stems so it's ready for "Add Another Entry" dialog
    ref.watch(savedStemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => context.go('/goals'),
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () => context.go('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.go('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateHeader(),
              const SizedBox(height: 16),

              // Streak cards (compact)
              streakData.when(
                data: (data) {
                  if (data.totalCompletionDays == 0) {
                    return const SizedBox.shrink();
                  }
                  return _CompactStreakRow(
                    currentStreak: data.currentStreak,
                    longestStreak: data.longestStreak,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Calendar (compact)
              streakData.when(
                data: (data) {
                  if (data.totalCompletionDays == 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CalendarWidget(
                      onDaySelected: (date, _) {
                        DayEntriesSheet.show(context, date);
                      },
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Pending resurfacing notification
              pendingResurfacing.when(
                data: (resurfacing) {
                  if (resurfacing.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.replay,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(
                          'Resurfacing Available',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                        subtitle: Text(
                          '${resurfacing.length} past ${resurfacing.length == 1 ? 'entry' : 'entries'} to revisit',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/resurfacing', extra: {
                            'resurfacingEntry': resurfacing.first,
                          });
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Goals progress
              goalsWithProgress.when(
                data: (goals) {
                  if (goals.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GoalProgressSummary(
                      goals: goals,
                      onViewAll: () => context.go('/goals'),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Today's status
              hasCompletedToday.when(
                data: (completed) {
                  if (completed) {
                    return todayEntry.when(
                      data: (entry) {
                        if (entry == null) return const SizedBox.shrink();
                        final count = todayEntryCount.valueOrNull ?? 1;
                        return _CompletedCard(
                          stemText: entry.stemText,
                          completion: entry.completion,
                          entryCount: count,
                          onTap: () => context.go('/entry/${entry.id}'),
                          onAddAnother: () =>
                              _showAddAnotherOptions(context, ref),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const SizedBox.shrink(),
                    );
                  }
                  final savedStemCount =
                      ref.watch(savedStemCountProvider).valueOrNull ?? 0;
                  return _StartCompletionCard(
                    savedStemCount: savedStemCount,
                    onSurpriseMe: () {
                      context.go('/completion');
                    },
                    onContinue: savedStemCount > 0
                        ? () {
                            context.go('/saved-stems');
                          }
                        : null,
                    onChooseCategory: () {
                      context.go('/category-selection');
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Error loading status'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayFormat = DateFormat('EEEE');
    final dateFormat = DateFormat('MMMM d, y');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayFormat.format(now),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          dateFormat.format(now),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _CompactStreakRow extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const _CompactStreakRow({
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactStreakCard(
            label: 'Current',
            value: currentStreak,
            icon: Icons.local_fire_department,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactStreakCard(
            label: 'Best',
            value: longestStreak,
            icon: Icons.emoji_events,
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}

class _CompactStreakCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final bool isPrimary;

  const _CompactStreakCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isPrimary ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final foregroundColor =
        isPrimary ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final iconColor = isPrimary ? colorScheme.primary : colorScheme.secondary;

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value ${value == 1 ? 'day' : 'days'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: foregroundColor.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String stemText;
  final String completion;
  final int entryCount;
  final VoidCallback onTap;
  final VoidCallback onAddAnother;

  const _CompletedCard({
    required this.stemText,
    required this.completion,
    required this.entryCount,
    required this.onTap,
    required this.onAddAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Latest Entry",
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$entryCount today',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    stemText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completion,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ResponsiveButton(
          child: OutlinedButton.icon(
            onPressed: onAddAnother,
            icon: const Icon(Icons.add),
            label: const Text('Add Another Entry'),
          ),
        ),
      ],
    );
  }
}

class _StartCompletionCard extends StatelessWidget {
  final int savedStemCount;
  final VoidCallback onSurpriseMe;
  final VoidCallback? onContinue;
  final VoidCallback onChooseCategory;

  const _StartCompletionCard({
    required this.savedStemCount,
    required this.onSurpriseMe,
    this.onContinue,
    required this.onChooseCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready for Today?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Complete a sentence stem to reflect',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveButton(
              child: FilledButton.icon(
                onPressed: onSurpriseMe,
                icon: const Icon(Icons.shuffle),
                label: const Text('Surprise Me'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (onContinue != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Icons.bookmark),
                      label: Text('Continue ($savedStemCount)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChooseCategory,
                    icon: const Icon(Icons.category),
                    label: const Text('Category'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
