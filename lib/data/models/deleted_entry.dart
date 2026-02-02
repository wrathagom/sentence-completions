/// Represents an entry that has been soft-deleted and can be restored
class DeletedEntry {
  final String id;
  final String originalId;
  final String stemId;
  final String stemText;
  final String completion;
  final DateTime createdAt;
  final DateTime deletedAt;
  final String categoryId;
  final String? parentEntryId;
  final int? resurfaceMonth;
  final List<String>? suggestedStems;
  final int? preMood;
  final int? postMood;
  final bool isFavorite;

  /// Number of days entries are retained before permanent deletion
  static const int retentionDays = 30;

  const DeletedEntry({
    required this.id,
    required this.originalId,
    required this.stemId,
    required this.stemText,
    required this.completion,
    required this.createdAt,
    required this.deletedAt,
    required this.categoryId,
    this.parentEntryId,
    this.resurfaceMonth,
    this.suggestedStems,
    this.preMood,
    this.postMood,
    this.isFavorite = false,
  });

  /// Whether this entry can still be restored (within retention period)
  bool get canRestore {
    final expirationDate = deletedAt.add(const Duration(days: retentionDays));
    return DateTime.now().isBefore(expirationDate);
  }

  /// Number of days remaining before permanent deletion
  int get daysRemaining {
    final expirationDate = deletedAt.add(const Duration(days: retentionDays));
    final remaining = expirationDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_id': originalId,
      'stem_id': stemId,
      'stem_text': stemText,
      'completion': completion,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt.toIso8601String(),
      'category_id': categoryId,
      'parent_entry_id': parentEntryId,
      'resurface_month': resurfaceMonth,
      'suggested_stems': suggestedStems?.join('|||'),
      'pre_mood': preMood,
      'post_mood': postMood,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Create from database map
  factory DeletedEntry.fromMap(Map<String, dynamic> map) {
    return DeletedEntry(
      id: map['id'] as String,
      originalId: map['original_id'] as String,
      stemId: map['stem_id'] as String,
      stemText: map['stem_text'] as String,
      completion: map['completion'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      deletedAt: DateTime.parse(map['deleted_at'] as String),
      categoryId: map['category_id'] as String,
      parentEntryId: map['parent_entry_id'] as String?,
      resurfaceMonth: map['resurface_month'] as int?,
      suggestedStems: map['suggested_stems'] != null
          ? (map['suggested_stems'] as String).split('|||')
          : null,
      preMood: map['pre_mood'] as int?,
      postMood: map['post_mood'] as int?,
      isFavorite: (map['is_favorite'] as int?) == 1,
    );
  }

  DeletedEntry copyWith({
    String? id,
    String? originalId,
    String? stemId,
    String? stemText,
    String? completion,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? categoryId,
    String? parentEntryId,
    int? resurfaceMonth,
    List<String>? suggestedStems,
    int? preMood,
    int? postMood,
    bool? isFavorite,
  }) {
    return DeletedEntry(
      id: id ?? this.id,
      originalId: originalId ?? this.originalId,
      stemId: stemId ?? this.stemId,
      stemText: stemText ?? this.stemText,
      completion: completion ?? this.completion,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      categoryId: categoryId ?? this.categoryId,
      parentEntryId: parentEntryId ?? this.parentEntryId,
      resurfaceMonth: resurfaceMonth ?? this.resurfaceMonth,
      suggestedStems: suggestedStems ?? this.suggestedStems,
      preMood: preMood ?? this.preMood,
      postMood: postMood ?? this.postMood,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
