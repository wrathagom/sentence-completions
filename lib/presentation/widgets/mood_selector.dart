import 'package:flutter/material.dart';

import '../../data/models/mood.dart';

class MoodSelector extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;
  final String? label;
  final bool compact;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Mood.values.map((mood) {
                final isSelected = selectedMood == mood;
                return GestureDetector(
                  onTap: () => onMoodSelected(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Tooltip(
                      message: mood.label,
                      child: Text(
                        mood.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 22,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Mood.values.map((mood) {
            final isSelected = selectedMood == mood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      mood.emoji,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MoodDisplay extends StatelessWidget {
  final Mood? mood;
  final String label;
  final bool compact;

  const MoodDisplay({
    super.key,
    required this.mood,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mood == null) return const SizedBox.shrink();

    if (compact) {
      return Tooltip(
        message: '$label: ${mood!.label}',
        child: Text(
          mood!.emoji,
          style: const TextStyle(fontSize: 20),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mood!.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              mood!.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
