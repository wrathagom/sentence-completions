class Category {
  final String id;
  final String name;
  final String? parentId;
  final String emoji;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.emoji,
    required this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      emoji: json['emoji'] as String,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'emoji': emoji,
      'sortOrder': sortOrder,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'emoji': emoji,
      'sort_order': sortOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      emoji: map['emoji'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? parentId,
    String? emoji,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
