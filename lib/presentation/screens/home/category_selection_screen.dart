import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/category.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  String _getEmojiDisplay(String emoji) {
    // Map emoji names to actual emojis
    const emojiMap = {
      'heart': '\u2764\ufe0f',
      'briefcase': '\u{1F4BC}',
      'brain': '\u{1F9E0}',
      'star': '\u2b50',
      'seedling': '\u{1F331}',
      'target': '\u{1F3AF}',
      'lightbulb': '\u{1F4A1}',
      'fire': '\u{1F525}',
      'rainbow': '\u{1F308}',
      'book': '\u{1F4D6}',
    };
    return emojiMap[emoji] ?? emoji;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Category'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories available'),
            );
          }

          return ResponsiveListView(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length + 1, // +1 for "Surprise Me"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _SurpriseMeCard(
                  onTap: () {
                    context.go('/completion');
                  },
                );
              }

              final category = categories[index - 1];
              return _CategoryCard(
                category: category,
                emoji: _getEmojiDisplay(category.emoji),
                onTap: () {
                  context.go('/completion', extra: {'categoryId': category.id});
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading categories: $error'),
        ),
      ),
    );
  }
}

class _SurpriseMeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SurpriseMeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.shuffle,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          'Surprise Me',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          'Random stem from any category',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.8),
              ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String emoji;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
