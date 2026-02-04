import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation.dart';
import '../../../core/responsive.dart';
import '../../../data/models/saved_stem.dart';
import '../../providers/providers.dart';

class SavedStemsScreen extends ConsumerWidget {
  const SavedStemsScreen({super.key});

  String _getRelativeTime(DateTime savedAt) {
    final now = DateTime.now();
    final difference = now.difference(savedAt);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return '1 hour ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return '1 minute ago';
      }
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _deleteSavedStem(
    BuildContext context,
    WidgetRef ref,
    SavedStem savedStem,
  ) async {
    final repository = ref.read(savedStemRepositoryProvider);
    await repository.deleteSavedStem(savedStem.id);
    ref.invalidate(savedStemsProvider);
    ref.invalidate(savedStemCountProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prompt removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await repository.restoreSavedStem(savedStem);
              ref.invalidate(savedStemsProvider);
              ref.invalidate(savedStemCountProvider);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedStems = ref.watch(savedStemsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
        title: const Text('Saved Prompts'),
      ),
      body: savedStems.when(
        data: (stems) {
          if (stems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved prompts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prompts you save for later will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.maxContentWidth ?? double.infinity,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: stems.length,
                itemBuilder: (context, index) {
              final savedStem = stems[index];
              return Dismissible(
                key: Key(savedStem.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Theme.of(context).colorScheme.error,
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                onDismissed: (_) => _deleteSavedStem(context, ref, savedStem),
                child: ListTile(
                  title: Text(
                    savedStem.stemText,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          'Saved ${_getRelativeTime(savedStem.savedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (savedStem.stemId.startsWith('ai_')) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Always pass both stemId and stemText for fallback support
                    context.push(
                      '/completion',
                      extra: {
                        'stemId': savedStem.stemId,
                        'stemText': savedStem.stemText,
                      },
                    );
                  },
                ),
              );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
