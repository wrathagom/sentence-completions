import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/entry.dart';
import '../../../data/models/stem_rating.dart';
import '../../providers/providers.dart';
import '../../widgets/glowing_card.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../widgets/stem_rating_widget.dart';

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;
  final bool showComparison;

  const EntryDetailScreen({
    super.key,
    required this.entryId,
    this.showComparison = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(entryByIdProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (showComparison) {
              context.go('/home');
            } else {
              context.go('/history');
            }
          },
        ),
        title: Text(showComparison ? 'Comparison' : 'Entry Details'),
        actions: [
          if (!showComparison) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => context.push('/share/$entryId'),
              tooltip: 'Share as image',
            ),
            entryAsync.when(
              data: (entry) {
                if (entry == null) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(
                    entry.isFavorite ? Icons.star : Icons.star_border,
                    color: entry.isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () => _toggleFavorite(ref, entry.id),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context, ref),
            ),
          ],
        ],
      ),
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }

          if (showComparison && entry.parentEntryId != null) {
            return _ComparisonView(entry: entry);
          }

          return _EntryDetailView(entry: entry);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading entry: $error'),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String id) async {
    final repository = ref.read(entryRepositoryProvider);
    await repository.toggleFavorite(id);
    ref.invalidate(entryByIdProvider(id));
    ref.invalidate(entriesProvider);
    ref.invalidate(favoriteEntriesProvider);
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'This entry will be moved to Recently Deleted. You can restore it within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repository = ref.read(entryRepositoryProvider);
      final deletedEntry = await repository.softDeleteEntry(entryId);
      ref.invalidate(entriesProvider);
      ref.invalidate(filteredEntriesProvider);
      ref.invalidate(hasCompletedTodayProvider);
      ref.invalidate(todayEntryProvider);
      ref.invalidate(deletedEntriesProvider);

      if (context.mounted) {
        context.go('/history');

        if (deletedEntry != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Entry deleted'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  final restoredEntry =
                      await repository.restoreEntry(deletedEntry.id);
                  if (restoredEntry != null) {
                    ref.invalidate(entriesProvider);
                    ref.invalidate(filteredEntriesProvider);
                    ref.invalidate(hasCompletedTodayProvider);
                    ref.invalidate(todayEntryProvider);
                    ref.invalidate(deletedEntriesProvider);
                  }
                },
              ),
            ),
          );
        }
      }
    }
  }
}

class _EntryDetailView extends ConsumerStatefulWidget {
  final Entry entry;

  const _EntryDetailView({required this.entry});

  @override
  ConsumerState<_EntryDetailView> createState() => _EntryDetailViewState();
}

class _EntryDetailViewState extends ConsumerState<_EntryDetailView> {
  StemRatingValue? _selectedRating;
  bool _ratingLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    final repository = ref.read(stemRatingRepositoryProvider);
    final rating = await repository.getRatingForEntry(widget.entry.id);
    if (mounted) {
      setState(() {
        _selectedRating = rating?.rating;
        _ratingLoaded = true;
      });
    }
  }

  Future<void> _rateStem(StemRatingValue rating) async {
    final repository = ref.read(stemRatingRepositoryProvider);
    await repository.rateStem(
      stemId: widget.entry.stemId,
      rating: rating,
      entryId: widget.entry.id,
    );

    setState(() {
      _selectedRating = rating;
    });

    ref.invalidate(stemRatingForStemProvider(widget.entry.stemId));
    ref.invalidate(stemRatingForEntryProvider(widget.entry.id));
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return ResponsiveCenter(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.isResurfaced)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.replay,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resurfaced after ${entry.resurfaceMonth} months',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
            ),
          Text(
            dateFormat.format(entry.createdAt),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            timeFormat.format(entry.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          GlowingCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentence Stem',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.stemText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowingCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Completion',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.completion,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowingCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stem Rating',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                if (!_ratingLoaded)
                  const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  StemRatingWidget(
                    selectedRating: _selectedRating,
                    onRatingSelected: _rateStem,
                    compact: true,
                  ),
              ],
            ),
          ),
          if (entry.preMood != null || entry.postMood != null) ...[
            const SizedBox(height: 16),
            GlowingCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (entry.preMood != null)
                        Expanded(
                          child: MoodDisplay(
                            mood: entry.preMood,
                            label: 'Before',
                          ),
                        ),
                      if (entry.preMood != null && entry.postMood != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (entry.postMood != null)
                        Expanded(
                          child: MoodDisplay(
                            mood: entry.postMood,
                            label: 'After',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (entry.suggestedStems != null && entry.suggestedStems!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Continue Reflecting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Prompts generated from this entry:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            ...entry.suggestedStems!.map((stem) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlowingCard(
                child: InkWell(
                  onTap: () => context.go('/completion', extra: {'stemText': stem}),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            stem,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _ComparisonView extends ConsumerWidget {
  final Entry entry;

  const _ComparisonView({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalEntryAsync = entry.parentEntryId != null
        ? ref.watch(entryByIdProvider(entry.parentEntryId!))
        : const AsyncValue<Entry?>.data(null);

    return originalEntryAsync.when(
      data: (originalEntry) {
        if (originalEntry == null) {
          return _EntryDetailView(entry: entry);
        }

        return ResponsiveCenter(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowingCard(
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'See how your answer has changed over ${entry.resurfaceMonth} months',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlowingCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sentence Stem',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.stemText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ComparisonCard(
                title: '${entry.resurfaceMonth} months ago',
                date: originalEntry.createdAt,
                completion: originalEntry.completion,
                isOriginal: true,
              ),
              const SizedBox(height: 12),
              _ComparisonCard(
                title: 'Today',
                date: entry.createdAt,
                completion: entry.completion,
                isOriginal: false,
              ),
              const SizedBox(height: 24),
              ResponsiveButton(
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading comparison: $error'),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String completion;
  final bool isOriginal;

  const _ComparisonCard({
    required this.title,
    required this.date,
    required this.completion,
    required this.isOriginal,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');

    return GlowingCard(
      color: isOriginal
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOriginal ? Icons.history : Icons.today,
                size: 18,
                color: isOriginal
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isOriginal
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.primary,
                    ),
              ),
              const Spacer(),
              Text(
                dateFormat.format(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            completion,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
