import 'package:flutter/material.dart';

import '../../data/models/entry_reaction.dart';

class ReactionButton extends StatelessWidget {
  final ReactionType reactionType;
  final bool isSelected;
  final VoidCallback onTap;

  const ReactionButton({
    super.key,
    required this.reactionType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reactionType.emoji,
              style: TextStyle(fontSize: isSelected ? 20 : 18),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                reactionType.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReactionChip extends StatelessWidget {
  final EntryReaction reaction;
  final VoidCallback? onRemove;

  const ReactionChip({
    super.key,
    required this.reaction,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            reaction.reactionType.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            reaction.reactionType.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReactionPicker extends StatelessWidget {
  final Set<ReactionType> selectedReactions;
  final ValueChanged<ReactionType> onReactionToggle;

  const ReactionPicker({
    super.key,
    required this.selectedReactions,
    required this.onReactionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReactionType.values.map((type) {
        final isSelected = selectedReactions.contains(type);
        return ReactionButton(
          reactionType: type,
          isSelected: isSelected,
          onTap: () => onReactionToggle(type),
        );
      }).toList(),
    );
  }
}

class ReactionSummary extends StatelessWidget {
  final List<EntryReaction> reactions;
  final VoidCallback? onTap;

  const ReactionSummary({
    super.key,
    required this.reactions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...reactions.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text(
                  r.reactionType.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              )),
          if (reactions.length > 3) ...[
            Text(
              '+${reactions.length - 3}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
