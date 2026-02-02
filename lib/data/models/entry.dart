import 'mood.dart';

class Entry {
  final String id;
  final String stemId;
  final String stemText;
  final String completion;
  final DateTime createdAt;
  final String categoryId;
  final String? parentEntryId;
  final int? resurfaceMonth;
  final List<String>? suggestedStems;
  final int? preMoodValue;
  final int? postMoodValue;

  const Entry({
    required this.id,
    required this.stemId,
    required this.stemText,
    required this.completion,
    required this.createdAt,
    required this.categoryId,
    this.parentEntryId,
    this.resurfaceMonth,
    this.suggestedStems,
    this.preMoodValue,
    this.postMoodValue,
  });

  Mood? get preMood => Mood.fromValueNullable(preMoodValue);
  Mood? get postMood => Mood.fromValueNullable(postMoodValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stem_id': stemId,
      'stem_text': stemText,
      'completion': completion,
      'created_at': createdAt.toIso8601String(),
      'category_id': categoryId,
      'parent_entry_id': parentEntryId,
      'resurface_month': resurfaceMonth,
      'suggested_stems': suggestedStems?.join('|||'),
      'pre_mood': preMoodValue,
      'post_mood': postMoodValue,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    final suggestedStemsRaw = map['suggested_stems'] as String?;
    return Entry(
      id: map['id'] as String,
      stemId: map['stem_id'] as String,
      stemText: map['stem_text'] as String,
      completion: map['completion'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      categoryId: map['category_id'] as String,
      parentEntryId: map['parent_entry_id'] as String?,
      resurfaceMonth: map['resurface_month'] as int?,
      suggestedStems: suggestedStemsRaw != null && suggestedStemsRaw.isNotEmpty
          ? suggestedStemsRaw.split('|||')
          : null,
      preMoodValue: map['pre_mood'] as int?,
      postMoodValue: map['post_mood'] as int?,
    );
  }

  Entry copyWith({
    String? id,
    String? stemId,
    String? stemText,
    String? completion,
    DateTime? createdAt,
    String? categoryId,
    String? parentEntryId,
    int? resurfaceMonth,
    List<String>? suggestedStems,
    int? preMoodValue,
    int? postMoodValue,
  }) {
    return Entry(
      id: id ?? this.id,
      stemId: stemId ?? this.stemId,
      stemText: stemText ?? this.stemText,
      completion: completion ?? this.completion,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      parentEntryId: parentEntryId ?? this.parentEntryId,
      resurfaceMonth: resurfaceMonth ?? this.resurfaceMonth,
      suggestedStems: suggestedStems ?? this.suggestedStems,
      preMoodValue: preMoodValue ?? this.preMoodValue,
      postMoodValue: postMoodValue ?? this.postMoodValue,
    );
  }

  bool get isResurfaced => parentEntryId != null;

  String get dateKey {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
