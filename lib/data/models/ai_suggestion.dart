import 'package:uuid/uuid.dart';

class AISuggestion {
  final String text;
  final String tempId;

  const AISuggestion({
    required this.text,
    required this.tempId,
  });

  factory AISuggestion.create(String text) {
    return AISuggestion(
      text: text,
      tempId: const Uuid().v4(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AISuggestion &&
          runtimeType == other.runtimeType &&
          tempId == other.tempId;

  @override
  int get hashCode => tempId.hashCode;
}
