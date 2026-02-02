enum ReactionType {
  insightful('insightful', 'Insightful', '💡'),
  proud('proud', 'Proud', '🌟'),
  growth('growth', 'Growth', '🌱'),
  grateful('grateful', 'Grateful', '🙏'),
  challenged('challenged', 'Challenged', '💪'),
  peaceful('peaceful', 'Peaceful', '🕊️');

  final String value;
  final String label;
  final String emoji;

  const ReactionType(this.value, this.label, this.emoji);

  static ReactionType fromValue(String value) {
    return ReactionType.values.firstWhere(
      (r) => r.value == value,
      orElse: () => ReactionType.insightful,
    );
  }

  String get displayLabel => '$emoji $label';
}

class EntryReaction {
  final String id;
  final String entryId;
  final ReactionType reactionType;
  final String? note;
  final DateTime createdAt;

  const EntryReaction({
    required this.id,
    required this.entryId,
    required this.reactionType,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_id': entryId,
      'reaction_type': reactionType.value,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EntryReaction.fromMap(Map<String, dynamic> map) {
    return EntryReaction(
      id: map['id'] as String,
      entryId: map['entry_id'] as String,
      reactionType: ReactionType.fromValue(map['reaction_type'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  EntryReaction copyWith({
    String? id,
    String? entryId,
    ReactionType? reactionType,
    String? note,
    DateTime? createdAt,
  }) {
    return EntryReaction(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      reactionType: reactionType ?? this.reactionType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
