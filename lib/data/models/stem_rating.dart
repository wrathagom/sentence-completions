enum StemRatingValue {
  negative(-1, '👎', 'Not for me'),
  neutral(0, '😐', 'Neutral'),
  positive(1, '👍', 'Resonated');

  final int value;
  final String emoji;
  final String label;

  const StemRatingValue(this.value, this.emoji, this.label);

  static StemRatingValue? fromValue(int? value) {
    if (value == null) return null;
    return StemRatingValue.values.firstWhere(
      (r) => r.value == value,
      orElse: () => StemRatingValue.neutral,
    );
  }
}

class StemRating {
  final String id;
  final String stemId;
  final StemRatingValue rating;
  final String? entryId;
  final DateTime ratedAt;

  const StemRating({
    required this.id,
    required this.stemId,
    required this.rating,
    this.entryId,
    required this.ratedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stem_id': stemId,
      'rating': rating.value,
      'entry_id': entryId,
      'rated_at': ratedAt.toIso8601String(),
    };
  }

  factory StemRating.fromMap(Map<String, dynamic> map) {
    return StemRating(
      id: map['id'] as String,
      stemId: map['stem_id'] as String,
      rating: StemRatingValue.fromValue(map['rating'] as int)!,
      entryId: map['entry_id'] as String?,
      ratedAt: DateTime.parse(map['rated_at'] as String),
    );
  }

  StemRating copyWith({
    String? id,
    String? stemId,
    StemRatingValue? rating,
    String? entryId,
    DateTime? ratedAt,
  }) {
    return StemRating(
      id: id ?? this.id,
      stemId: stemId ?? this.stemId,
      rating: rating ?? this.rating,
      entryId: entryId ?? this.entryId,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }
}
