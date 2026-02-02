import 'package:flutter/material.dart';

import '../../data/models/stem_rating.dart';

class StemRatingWidget extends StatelessWidget {
  final StemRatingValue? selectedRating;
  final ValueChanged<StemRatingValue> onRatingSelected;
  final bool compact;

  const StemRatingWidget({
    super.key,
    required this.selectedRating,
    required this.onRatingSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RatingButton(
            rating: StemRatingValue.negative,
            isSelected: selectedRating == StemRatingValue.negative,
            onTap: () => onRatingSelected(StemRatingValue.negative),
            compact: true,
          ),
          const SizedBox(width: 8),
          _RatingButton(
            rating: StemRatingValue.neutral,
            isSelected: selectedRating == StemRatingValue.neutral,
            onTap: () => onRatingSelected(StemRatingValue.neutral),
            compact: true,
          ),
          const SizedBox(width: 8),
          _RatingButton(
            rating: StemRatingValue.positive,
            isSelected: selectedRating == StemRatingValue.positive,
            onTap: () => onRatingSelected(StemRatingValue.positive),
            compact: true,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did this prompt feel?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: StemRatingValue.values.map((rating) {
            return _RatingButton(
              rating: rating,
              isSelected: selectedRating == rating,
              onTap: () => onRatingSelected(rating),
              compact: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final StemRatingValue rating;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const _RatingButton({
    required this.rating,
    required this.isSelected,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Text(
            rating.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              rating.emoji,
              style: TextStyle(
                fontSize: isSelected ? 32 : 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rating.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class StemRatingDisplay extends StatelessWidget {
  final StemRatingValue rating;

  const StemRatingDisplay({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rating.emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          rating.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
