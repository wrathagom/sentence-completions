class SavedStem {
  final String id;
  final String stemId;
  final String stemText;
  final String categoryId;
  final DateTime savedAt;
  final String? sourceEntryId;

  const SavedStem({
    required this.id,
    required this.stemId,
    required this.stemText,
    required this.categoryId,
    required this.savedAt,
    this.sourceEntryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stem_id': stemId,
      'stem_text': stemText,
      'category_id': categoryId,
      'saved_at': savedAt.toIso8601String(),
      'source_entry_id': sourceEntryId,
    };
  }

  factory SavedStem.fromMap(Map<String, dynamic> map) {
    return SavedStem(
      id: map['id'] as String,
      stemId: map['stem_id'] as String,
      stemText: map['stem_text'] as String,
      categoryId: map['category_id'] as String,
      savedAt: DateTime.parse(map['saved_at'] as String),
      sourceEntryId: map['source_entry_id'] as String?,
    );
  }

  SavedStem copyWith({
    String? id,
    String? stemId,
    String? stemText,
    String? categoryId,
    DateTime? savedAt,
    String? sourceEntryId,
  }) {
    return SavedStem(
      id: id ?? this.id,
      stemId: stemId ?? this.stemId,
      stemText: stemText ?? this.stemText,
      categoryId: categoryId ?? this.categoryId,
      savedAt: savedAt ?? this.savedAt,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedStem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
