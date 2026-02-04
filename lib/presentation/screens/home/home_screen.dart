import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../data/models/analytics_data.dart';
import '../../../data/models/entry.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/user_settings.dart';
import '../../providers/providers.dart';
import '../../widgets/glowing_card.dart';
import '../../widgets/goal_progress_card.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/scroll_aware_scaffold.dart';
import '../../widgets/word_cloud_widget.dart';
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
                  context.push('/saved-stems');
                  },
                  icon: const Icon(Icons.bookmark),
                  label: Text('Continue ($savedStemCount saved)'),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/category-selection');
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

  void _showStartOptions(BuildContext context, WidgetRef ref) {
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
                'Start Today\'s Entry',
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
                    context.push('/saved-stems');
                  },
                  icon: const Icon(Icons.bookmark),
                  label: Text('Continue ($savedStemCount saved)'),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/category-selection');
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
    final todayEntryCount = ref.watch(todayEntryCountProvider);
    final latestEntry = ref.watch(latestEntryProvider);
    final pendingResurfacing = ref.watch(pendingResurfacingProvider);
    final streakData = ref.watch(streakDataProvider);
    final goalsWithProgress = ref.watch(activeGoalsWithProgressProvider);
    final favoriteEntries = ref.watch(favoriteEntriesProvider);
    final analyticsData = ref.watch(analyticsDataProvider);
    final settings = ref.watch(settingsProvider);
    // Pre-fetch saved stems so it's ready for entry dialogs
    ref.watch(savedStemsProvider);

    return ScrollAwareScaffold(
      title: AppConstants.appName,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
        ),
      ],
      bottomNavigationBar: _FixedEntryButton(
        hasCompletedToday: hasCompletedToday.valueOrNull ?? false,
        onStartEntry: () => _showStartOptions(context, ref),
        onAddAnother: () => _showAddAnotherOptions(context, ref),
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
                    child: GlowingCard(
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

              // Latest entry preview
              latestEntry.when(
                data: (entry) {
                  if (entry == null) return const SizedBox.shrink();
                  final todayCount = todayEntryCount.valueOrNull ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LatestEntryPreview(
                      entry: entry,
                      todayEntryCount: todayCount,
                      onTap: () => context.push('/entry/${entry.id}'),
                      onShowAllEntries: () => context.push('/history'),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Goals Feed Section
              _GoalsFeedSection(
                goalsAsync: goalsWithProgress,
                onViewAll: () => context.push('/goals'),
                onCreateGoal: () => context.push('/goals'),
              ),

              // Favorites Feed Section
              _FavoritesFeedSection(
                favoritesAsync: favoriteEntries,
                onViewAll: () => context.push('/favorites'),
                onEntryTap: (entry) => context.push('/entry/${entry.id}'),
              ),

              // Analytics Feed Section
              _AnalyticsFeedSection(
                analyticsAsync: analyticsData,
                settings: settings,
                onViewAll: () => context.push('/analytics'),
              ),

              // Space for fixed button
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedEntryButton extends StatelessWidget {
  final bool hasCompletedToday;
  final VoidCallback onStartEntry;
  final VoidCallback onAddAnother;

  const _FixedEntryButton({
    required this.hasCompletedToday,
    required this.onStartEntry,
    required this.onAddAnother,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: hasCompletedToday
            ? OutlinedButton.icon(
                onPressed: onAddAnother,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Entry'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            : FilledButton.icon(
                onPressed: onStartEntry,
                icon: const Icon(Icons.edit_note),
                label: const Text('Start Today\'s Entry'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
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

    return GlowingCard(
      color: backgroundColor,
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
    );
  }
}

class _LatestEntryPreview extends StatelessWidget {
  final Entry entry;
  final int todayEntryCount;
  final VoidCallback onTap;
  final VoidCallback onShowAllEntries;

  const _LatestEntryPreview({
    required this.entry,
    required this.todayEntryCount,
    required this.onTap,
    required this.onShowAllEntries,
  });

  String _getTimeLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
    );

    if (entryDate == today) {
      if (todayEntryCount > 1) {
        return '$todayEntryCount today';
      }
      return 'Today';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (entryDate == yesterday) {
      return 'Yesterday';
    }

    final difference = today.difference(entryDate).inDays;
    if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlowingCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_outlined,
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
                  _getTimeLabel(),
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
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.stemText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.completion,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onShowAllEntries,
              child: const Text('Show all entries →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsFeedSection extends StatelessWidget {
  final AsyncValue<List<GoalWithProgress>> goalsAsync;
  final VoidCallback onViewAll;
  final VoidCallback onCreateGoal;

  const _GoalsFeedSection({
    required this.goalsAsync,
    required this.onViewAll,
    required this.onCreateGoal,
  });

  @override
  Widget build(BuildContext context) {
    return goalsAsync.when(
      data: (goals) {
        final completedCount = goals.where((g) => g.isCompleted).length;
        // Sort: uncompleted first, then completed
        final sortedGoals = [...goals]..sort((a, b) {
            if (a.isCompleted == b.isCompleted) return 0;
            return a.isCompleted ? 1 : -1;
          });

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlowingCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Goals',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (goals.isNotEmpty)
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
                          '$completedCount/${goals.length} Goals Met',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                  ],
                ),
                if (goals.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Set goals to track your progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onCreateGoal,
                    icon: const Icon(Icons.add),
                    label: const Text('Create a new goal'),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  ...sortedGoals.take(2).map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GoalProgressCard(
                          goalWithProgress: g,
                          compact: true,
                        ),
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onViewAll,
                      child: const Text('Manage Goals →'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _FavoritesFeedSection extends StatelessWidget {
  final AsyncValue<List<Entry>> favoritesAsync;
  final VoidCallback onViewAll;
  final void Function(Entry) onEntryTap;

  const _FavoritesFeedSection({
    required this.favoritesAsync,
    required this.onViewAll,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    return favoritesAsync.when(
      data: (favorites) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlowingCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (favorites.isNotEmpty)
                      TextButton(
                        onPressed: onViewAll,
                        child: const Text('View All →'),
                      ),
                  ],
                ),
                if (favorites.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Favorite an entry to have it show up here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  ...favorites.take(2).map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FavoriteEntryPreview(
                          entry: entry,
                          onTap: () => onEntryTap(entry),
                        ),
                      )),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _FavoriteEntryPreview extends StatelessWidget {
  final Entry entry;
  final VoidCallback onTap;

  const _FavoriteEntryPreview({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.stemText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              entry.completion,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsFeedSection extends StatelessWidget {
  final AsyncValue<AnalyticsData> analyticsAsync;
  final UserSettings settings;
  final VoidCallback onViewAll;

  const _AnalyticsFeedSection({
    required this.analyticsAsync,
    required this.settings,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return analyticsAsync.when(
      data: (data) {
        // Don't show if no entries yet
        if (data.totalEntries == 0) {
          return const SizedBox.shrink();
        }

        final enabledWidgets = settings.homeAnalyticsWidgets;
        if (enabledWidgets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlowingCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Analytics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats Row
                if (enabledWidgets.contains(HomeAnalyticsWidget.statsRow)) ...[
                  _CompactStatsRow(data: data),
                  const SizedBox(height: 12),
                ],

                // Word Cloud
                if (enabledWidgets.contains(HomeAnalyticsWidget.wordCloud)) ...[
                  SizedBox(
                    height: 150,
                    child: WordCloudWidget(
                      words: data.topWords.take(20).toList(),
                      minFontSize: 10,
                      maxFontSize: 24,
                    ),
                  ),
                  if (enabledWidgets.contains(HomeAnalyticsWidget.categoryPieChart))
                    const SizedBox(height: 12),
                ],

                // Category Pie Chart
                if (enabledWidgets.contains(HomeAnalyticsWidget.categoryPieChart) &&
                    data.categoryDistribution.isNotEmpty)
                  _CompactCategoryChart(distribution: data.categoryDistribution),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _CompactStatsRow extends StatelessWidget {
  final AnalyticsData data;

  const _CompactStatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactStatItem(
            value: data.totalEntries.toString(),
            label: 'Entries',
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _CompactStatItem(
            value: data.totalWords.toString(),
            label: 'Words',
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _CompactStatItem(
            value: data.uniqueStems.toString(),
            label: 'Prompts',
          ),
        ),
      ],
    );
  }
}

class _CompactStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _CompactStatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
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

class _CompactCategoryChart extends StatelessWidget {
  final List<CategoryDistribution> distribution;

  const _CompactCategoryChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    final topCategories = distribution.take(5).toList();

    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 25,
                sections: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;
                  return PieChartSectionData(
                    value: cat.entryCount.toDouble(),
                    title: '',
                    color: colors[index % colors.length],
                    radius: 30,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${cat.percentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
