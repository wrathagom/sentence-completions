import 'package:flutter/material.dart';

import '../../data/models/goal.dart';

class GoalProgressCard extends StatelessWidget {
  final GoalWithProgress goalWithProgress;
  final VoidCallback? onTap;
  final bool compact;

  const GoalProgressCard({
    super.key,
    required this.goalWithProgress,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final goal = goalWithProgress.goal;
    final progress = goalWithProgress.progressPercent;
    final isCompleted = goalWithProgress.isCompleted;

    if (compact) {
      return _CompactGoalCard(
        goalWithProgress: goalWithProgress,
        onTap: onTap,
      );
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    goal.type == GoalType.entries
                        ? Icons.edit_note
                        : Icons.local_fire_department,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.displayDescription,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goalWithProgress.currentProgress} / ${goal.target}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _getPeriodText(goal.period),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodText(GoalPeriod period) {
    switch (period) {
      case GoalPeriod.daily:
        return 'Today';
      case GoalPeriod.weekly:
        return 'This week';
      case GoalPeriod.monthly:
        return 'This month';
    }
  }
}

class _CompactGoalCard extends StatelessWidget {
  final GoalWithProgress goalWithProgress;
  final VoidCallback? onTap;

  const _CompactGoalCard({
    required this.goalWithProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final goal = goalWithProgress.goal;
    final progress = goalWithProgress.progressPercent;
    final isCompleted = goalWithProgress.isCompleted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor:
                        Theme.of(context).colorScheme.surface,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  Center(
                    child: Icon(
                      isCompleted ? Icons.check : _getGoalIcon(goal.type),
                      size: 18,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${goalWithProgress.currentProgress}/${goal.target} ${goal.type.label.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    goal.period.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.entries:
        return Icons.edit_note;
      case GoalType.streak:
        return Icons.local_fire_department;
    }
  }
}

class GoalProgressSummary extends StatelessWidget {
  final List<GoalWithProgress> goals;
  final VoidCallback? onViewAll;

  const GoalProgressSummary({
    super.key,
    required this.goals,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    final completedCount = goals.where((g) => g.isCompleted).length;
    final totalCount = goals.length;

    return Card(
      child: Padding(
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
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            ...goals.take(2).map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GoalProgressCard(
                    goalWithProgress: g,
                    compact: true,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
