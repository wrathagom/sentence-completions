import 'package:flutter/material.dart';

import '../../data/models/stem_rating.dart';

class PromptReactionPicker extends StatelessWidget {
  final StemRatingValue? selectedReaction;
  final ValueChanged<StemRatingValue?> onReactionChanged;
  final bool analyticsEnabled;

  const PromptReactionPicker({
    super.key,
    required this.selectedReaction,
    required this.onReactionChanged,
    this.analyticsEnabled = false,
  });

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why we ask'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your reactions help us personalize your journaling experience:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const _InfoItem(
              icon: Icons.lightbulb_outline,
              text: 'Suggest prompts that resonate with you',
            ),
            const SizedBox(height: 8),
            const _InfoItem(
              icon: Icons.library_books_outlined,
              text: 'Improve our prompt library over time',
            ),
            const SizedBox(height: 8),
            const _InfoItem(
              icon: Icons.track_changes,
              text: 'Track patterns in what inspires you',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  analyticsEnabled ? Icons.cloud_outlined : Icons.lock_outline,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    analyticsEnabled
                        ? 'Since you have analytics enabled, we collect your prompt reactions completely anonymously.'
                        : 'Your reactions stay on your device and are never shared.',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'How does this prompt make you feel?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            GestureDetector(
              onTap: () => _showInfoDialog(context),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: StemRatingValue.values.map((reaction) {
            final isSelected = selectedReaction == reaction;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  // Toggle off if already selected, otherwise select
                  if (isSelected) {
                    onReactionChanged(null);
                  } else {
                    onReactionChanged(reaction);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    reaction.emoji,
                    style: TextStyle(fontSize: isSelected ? 24 : 22),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
