import '../../data/models/stem.dart';
import '../../data/repositories/stem_repository.dart';

class SuggestionService {
  final StemRepository _stemRepository;

  SuggestionService({required StemRepository stemRepository})
      : _stemRepository = stemRepository;

  // Common stop words to filter out
  static const _stopWords = {
    'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your',
    'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she',
    'her', 'hers', 'herself', 'it', 'its', 'itself', 'they', 'them', 'their',
    'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that',
    'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an',
    'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of',
    'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through',
    'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down',
    'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then',
    'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'each',
    'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only',
    'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just',
    'don', 'should', 'now', 'd', 'll', 'm', 'o', 're', 've', 'y', 'ain', 'aren',
    'couldn', 'didn', 'doesn', 'hadn', 'hasn', 'haven', 'isn', 'ma', 'mightn',
    'mustn', 'needn', 'shan', 'shouldn', 'wasn', 'weren', 'won', 'wouldn',
    'really', 'think', 'feel', 'want', 'need', 'know', 'like', 'would', 'could',
    'always', 'never', 'sometimes', 'often', 'much', 'many', 'lot', 'thing',
    'things', 'way', 'something', 'anything', 'everything', 'nothing', 'someone',
    'anyone', 'everyone', 'one', 'two', 'three', 'first', 'second', 'last',
    'make', 'made', 'get', 'got', 'going', 'also', 'even', 'still',
    'already', 'yet', 'today', 'yesterday', 'tomorrow', 'time', 'times',
  };

  /// Extracts significant keywords from a completion text
  List<String> extractKeywords(String completion) {
    // Lowercase and remove punctuation
    final cleaned = completion
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Split into words and filter
    final words = cleaned.split(' ').where((word) {
      // Must be at least 4 characters
      if (word.length < 4) return false;
      // Must not be a stop word
      if (_stopWords.contains(word)) return false;
      // Must contain at least one letter
      if (!RegExp(r'[a-z]').hasMatch(word)) return false;
      return true;
    }).toList();

    // Remove duplicates while preserving order
    final seen = <String>{};
    return words.where((word) => seen.add(word)).toList();
  }

  /// Gets suggested stems based on completion keywords
  Future<List<Stem>> getSuggestedStems({
    required String completion,
    required String excludeStemId,
    int limit = 3,
  }) async {
    // Extract keywords from completion
    final keywords = extractKeywords(completion);

    List<Stem> suggestions = [];

    // Try to find stems matching keywords
    if (keywords.isNotEmpty) {
      suggestions = await _stemRepository.getStemsByKeywords(
        keywords: keywords,
        excludeStemId: excludeStemId,
        limit: limit,
      );
    }

    // If we didn't get enough suggestions, backfill with random stems
    if (suggestions.length < limit) {
      final excludeIds = {excludeStemId, ...suggestions.map((s) => s.id)};
      final randomStems = await _stemRepository.getRandomStems(
        excludeStemId: excludeStemId,
        limit: limit - suggestions.length + excludeIds.length,
      );

      // Filter out any stems we already have
      final additionalStems = randomStems
          .where((s) => !excludeIds.contains(s.id))
          .take(limit - suggestions.length)
          .toList();

      suggestions.addAll(additionalStems);
    }

    return suggestions.take(limit).toList();
  }
}
