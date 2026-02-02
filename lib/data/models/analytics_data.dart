class WordFrequency {
  final String word;
  final int count;
  final double normalizedSize;

  const WordFrequency({
    required this.word,
    required this.count,
    this.normalizedSize = 1.0,
  });

  WordFrequency copyWith({
    String? word,
    int? count,
    double? normalizedSize,
  }) {
    return WordFrequency(
      word: word ?? this.word,
      count: count ?? this.count,
      normalizedSize: normalizedSize ?? this.normalizedSize,
    );
  }
}

class CategoryDistribution {
  final String categoryId;
  final String categoryName;
  final String? emoji;
  final int entryCount;
  final double percentage;

  const CategoryDistribution({
    required this.categoryId,
    required this.categoryName,
    this.emoji,
    required this.entryCount,
    required this.percentage,
  });
}

class AnalyticsData {
  final int totalEntries;
  final int totalWords;
  final double averageWordsPerEntry;
  final List<WordFrequency> topWords;
  final List<CategoryDistribution> categoryDistribution;
  final Map<String, int> entriesByMonth;
  final int uniqueStems;

  const AnalyticsData({
    required this.totalEntries,
    required this.totalWords,
    required this.averageWordsPerEntry,
    required this.topWords,
    required this.categoryDistribution,
    required this.entriesByMonth,
    required this.uniqueStems,
  });

  factory AnalyticsData.empty() {
    return const AnalyticsData(
      totalEntries: 0,
      totalWords: 0,
      averageWordsPerEntry: 0,
      topWords: [],
      categoryDistribution: [],
      entriesByMonth: {},
      uniqueStems: 0,
    );
  }
}
