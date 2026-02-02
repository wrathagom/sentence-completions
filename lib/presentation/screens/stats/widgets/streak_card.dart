import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SingleStreakCard(
            label: 'Current',
            value: currentStreak,
            icon: Icons.local_fire_department,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SingleStreakCard(
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

class _SingleStreakCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final bool isPrimary;

  const _SingleStreakCard({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
            ),
            Text(
              value == 1 ? 'day' : 'days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foregroundColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
