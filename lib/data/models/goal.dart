enum GoalPeriod {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  final String value;
  final String label;

  const GoalPeriod(this.value, this.label);

  static GoalPeriod fromValue(String value) {
    return GoalPeriod.values.firstWhere(
      (p) => p.value == value,
      orElse: () => GoalPeriod.weekly,
    );
  }
}

enum GoalType {
  entries('entries', 'Entries', 'Complete entries'),
  streak('streak', 'Streak', 'Maintain a streak');

  final String value;
  final String label;
  final String description;

  const GoalType(this.value, this.label, this.description);

  static GoalType fromValue(String value) {
    return GoalType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => GoalType.entries,
    );
  }
}

class Goal {
  final String id;
  final GoalType type;
  final int target;
  final GoalPeriod period;
  final DateTime createdAt;
  final bool isActive;

  const Goal({
    required this.id,
    required this.type,
    required this.target,
    required this.period,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'target': target,
      'period': period.value,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      type: GoalType.fromValue(map['type'] as String),
      target: map['target'] as int,
      period: GoalPeriod.fromValue(map['period'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Goal copyWith({
    String? id,
    GoalType? type,
    int? target,
    GoalPeriod? period,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get displayTarget {
    final unit = type == GoalType.entries ? 'entries' : 'days';
    return '$target $unit';
  }

  String get displayDescription {
    switch (type) {
      case GoalType.entries:
        return 'Complete $target entries ${period.label.toLowerCase()}';
      case GoalType.streak:
        return 'Maintain a $target day streak';
    }
  }
}

class GoalProgress {
  final String id;
  final String goalId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int achieved;

  const GoalProgress({
    required this.id,
    required this.goalId,
    required this.periodStart,
    required this.periodEnd,
    this.achieved = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'achieved': achieved,
    };
  }

  factory GoalProgress.fromMap(Map<String, dynamic> map) {
    return GoalProgress(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      periodStart: DateTime.parse(map['period_start'] as String),
      periodEnd: DateTime.parse(map['period_end'] as String),
      achieved: map['achieved'] as int,
    );
  }

  GoalProgress copyWith({
    String? id,
    String? goalId,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? achieved,
  }) {
    return GoalProgress(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      achieved: achieved ?? this.achieved,
    );
  }
}

class GoalWithProgress {
  final Goal goal;
  final int currentProgress;
  final GoalProgress? progress;

  const GoalWithProgress({
    required this.goal,
    required this.currentProgress,
    this.progress,
  });

  double get progressPercent {
    if (goal.target == 0) return 0;
    return (currentProgress / goal.target).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentProgress >= goal.target;

  int get remaining => (goal.target - currentProgress).clamp(0, goal.target);
}
