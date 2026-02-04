import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation.dart';
import '../../../data/models/goal.dart';
import '../../providers/providers.dart';
import '../../widgets/responsive_scaffold.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  GoalType _selectedType = GoalType.entries;
  GoalPeriod _selectedPeriod = GoalPeriod.weekly;
  int _target = 3;
  bool _isCreating = false;

  final List<int> _entryTargetOptions = [1, 3, 5, 7, 10, 14, 21];
  final List<int> _streakTargetOptions = [3, 7, 14, 21, 30, 60, 90];

  List<int> get _currentTargetOptions =>
      _selectedType == GoalType.entries
          ? _entryTargetOptions
          : _streakTargetOptions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.safePop(),
        ),
        title: const Text('Create Goal'),
      ),
      body: ResponsiveCenter(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Type Selection
            Text(
              'What do you want to track?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: GoalType.values.map((type) {
                final isSelected = _selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: type != GoalType.values.last ? 8 : 0,
                    ),
                    child: _SelectionCard(
                      title: type.label,
                      description: type.description,
                      icon: type == GoalType.entries
                          ? Icons.edit_note
                          : Icons.local_fire_department,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                          // Reset target to a reasonable default for the type
                          _target = _currentTargetOptions[1];
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Period Selection (only for entries)
            if (_selectedType == GoalType.entries) ...[
              Text(
                'How often?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: GoalPeriod.values.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return ChoiceChip(
                    label: Text(period.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Target Selection
            Text(
              _selectedType == GoalType.entries
                  ? 'How many entries?'
                  : 'How long a streak?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentTargetOptions.map((target) {
                final isSelected = _target == target;
                final label = _selectedType == GoalType.entries
                    ? '$target'
                    : '$target days';
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _target = target;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Preview
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Goal',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getGoalDescription(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ResponsiveButton(
              child: FilledButton(
                onPressed: _isCreating ? null : _createGoal,
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalDescription() {
    switch (_selectedType) {
      case GoalType.entries:
        return 'Complete $_target entries ${_selectedPeriod.label.toLowerCase()}';
      case GoalType.streak:
        return 'Maintain a $_target day streak';
    }
  }

  Future<void> _createGoal() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final service = ref.read(goalServiceProvider);
      await service.createGoal(
        type: _selectedType,
        target: _target,
        period: _selectedType == GoalType.entries
            ? _selectedPeriod
            : GoalPeriod.daily, // Streak goals don't use period
      );

      ref.invalidate(activeGoalsWithProgressProvider);

      if (mounted) {
        context.safePop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
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
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.8)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
