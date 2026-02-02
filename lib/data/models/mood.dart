enum Mood {
  veryLow(1, '😢', 'Very Low'),
  low(2, '😕', 'Low'),
  neutral(3, '😐', 'Neutral'),
  good(4, '🙂', 'Good'),
  veryGood(5, '😊', 'Very Good');

  final int value;
  final String emoji;
  final String label;

  const Mood(this.value, this.emoji, this.label);

  static Mood? fromValue(int? value) {
    if (value == null) return null;
    return Mood.values.firstWhere(
      (m) => m.value == value,
      orElse: () => Mood.neutral,
    );
  }

  static Mood? fromValueNullable(int? value) {
    if (value == null) return null;
    try {
      return Mood.values.firstWhere((m) => m.value == value);
    } catch (_) {
      return null;
    }
  }

  String get displayLabel => '$emoji $label';

  bool get isPositive => value >= 4;
  bool get isNegative => value <= 2;
  bool get isNeutral => value == 3;
}
