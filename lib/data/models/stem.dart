class Stem {
  final String id;
  final String text;
  final String categoryId;
  final List<String> keywords;
  final int difficultyLevel;
  final bool isFoundational;

  const Stem({
    required this.id,
    required this.text,
    required this.categoryId,
    required this.keywords,
    required this.difficultyLevel,
    required this.isFoundational,
  });

  factory Stem.fromJson(Map<String, dynamic> json) {
    return Stem(
      id: json['id'] as String,
      text: json['text'] as String,
      categoryId: json['categoryId'] as String,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      difficultyLevel: json['difficultyLevel'] as int,
      isFoundational: json['isFoundational'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'categoryId': categoryId,
      'keywords': keywords,
      'difficultyLevel': difficultyLevel,
      'isFoundational': isFoundational,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category_id': categoryId,
      'keywords': keywords.join(','),
      'difficulty_level': difficultyLevel,
      'is_foundational': isFoundational ? 1 : 0,
    };
  }

  factory Stem.fromMap(Map<String, dynamic> map) {
    return Stem(
      id: map['id'] as String,
      text: map['text'] as String,
      categoryId: map['category_id'] as String,
      keywords: (map['keywords'] as String).split(','),
      difficultyLevel: map['difficulty_level'] as int,
      isFoundational: map['is_foundational'] == 1,
    );
  }

  Stem copyWith({
    String? id,
    String? text,
    String? categoryId,
    List<String>? keywords,
    int? difficultyLevel,
    bool? isFoundational,
  }) {
    return Stem(
      id: id ?? this.id,
      text: text ?? this.text,
      categoryId: categoryId ?? this.categoryId,
      keywords: keywords ?? this.keywords,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isFoundational: isFoundational ?? this.isFoundational,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
