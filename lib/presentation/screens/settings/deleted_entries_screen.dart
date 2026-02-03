import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/models/deleted_entry.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class DeletedEntriesScreen extends ConsumerWidget {
  const DeletedEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedEntriesAsync = ref.watch(deletedEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recently Deleted'),
        actions: [
          deletedEntriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _showClearAllDialog(context, ref),
                tooltip: 'Clear all',
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: deletedEntriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No deleted entries',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deleted entries appear here for 30 days',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ResponsiveCenter(
            scrollable: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Entries will be permanently deleted after 30 days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                ...entries.map((entry) => _DeletedEntryCard(entry: entry)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading deleted entries: $error'),
        ),
      ),
    );
  }

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text(
          'Are you sure you want to permanently delete all entries? This cannot be undone.',
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
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final deletedEntries = ref.read(deletedEntriesProvider).valueOrNull ?? [];
      final repository = ref.read(entryRepositoryProvider);

      for (final entry in deletedEntries) {
        await repository.permanentlyDeleteEntry(entry.id);
      }

      ref.invalidate(deletedEntriesProvider);
    }
  }
}

class _DeletedEntryCard extends ConsumerWidget {
  final DeletedEntry entry;

  const _DeletedEntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(entry.createdAt),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry.canRestore
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.daysRemaining} days left',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: entry.canRestore
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.stemText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              entry.completion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Deleted ${dateFormat.format(entry.deletedAt)} at ${timeFormat.format(entry.deletedAt)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showPermanentDeleteDialog(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete Forever'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: entry.canRestore
                      ? () => _restoreEntry(context, ref)
                      : null,
                  child: const Text('Restore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreEntry(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(entryRepositoryProvider);
    final restoredEntry = await repository.restoreEntry(entry.id);

    if (restoredEntry != null) {
      ref.invalidate(deletedEntriesProvider);
      ref.invalidate(entriesProvider);
      ref.invalidate(filteredEntriesProvider);
      ref.invalidate(hasCompletedTodayProvider);
      ref.invalidate(todayEntryProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry restored'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showPermanentDeleteDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forever'),
        content: const Text(
          'Are you sure you want to permanently delete this entry? This cannot be undone.',
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
      await repository.permanentlyDeleteEntry(entry.id);
      ref.invalidate(deletedEntriesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry permanently deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
