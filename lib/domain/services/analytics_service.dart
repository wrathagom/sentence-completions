import 'package:intl/intl.dart';

import '../../data/models/analytics_data.dart';
import '../../data/models/category.dart';
import '../../data/models/entry.dart';
import '../../data/repositories/entry_repository.dart';
import '../../data/repositories/stem_repository.dart';

class AnalyticsService {
  final EntryRepository _entryRepository;
  final StemRepository _stemRepository;

  static const _stopWords = {
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'is', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'shall', 'can', 'need',
    'dare', 'ought', 'used', 'i', 'me', 'my', 'myself', 'we', 'our',
    'ours', 'ourselves', 'you', 'your', 'yours', 'yourself', 'yourselves',
    'he', 'him', 'his', 'himself', 'she', 'her', 'hers', 'herself', 'it',
    'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves',
    'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those',
    'am', 'as', 'if', 'so', 'than', 'too', 'very', 'just', 'also',
    'now', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'each',
    'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such', 'no',
    'nor', 'not', 'only', 'own', 'same', 'then', 'into', 'about', 'after',
    'before', 'between', 'through', 'during', 'above', 'below', 'up',
    'down', 'out', 'off', 'over', 'under', 'again', 'further', 'once',
    'because', 'while', 'although', 'since', 'unless', 'until', 'though',
  };

  AnalyticsService({
    required EntryRepository entryRepository,
    required StemRepository stemRepository,
  })  : _entryRepository = entryRepository,
        _stemRepository = stemRepository;

  Future<AnalyticsData> getAnalytics() async {
    final entries = await _entryRepository.getAllEntries();
    final categories = await _stemRepository.getAllCategories();

    if (entries.isEmpty) {
      return AnalyticsData.empty();
    }

    final wordFrequencies = _calculateWordFrequencies(entries);
    final categoryDistribution = _calculateCategoryDistribution(entries, categories);
    final entriesByMonth = _calculateEntriesByMonth(entries);
    final uniqueStems = entries.map((e) => e.stemId).toSet().length;

    int totalWords = 0;
    for (final entry in entries) {
      totalWords += _countWords(entry.completion);
    }

    return AnalyticsData(
      totalEntries: entries.length,
      totalWords: totalWords,
      averageWordsPerEntry: totalWords / entries.length,
      topWords: wordFrequencies,
      categoryDistribution: categoryDistribution,
      entriesByMonth: entriesByMonth,
      uniqueStems: uniqueStems,
    );
  }

  int _countWords(String text) {
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  List<WordFrequency> _calculateWordFrequencies(List<Entry> entries, {int limit = 50}) {
    final wordCounts = <String, int>{};

    for (final entry in entries) {
      final words = entry.completion
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 2 && !_stopWords.contains(word));

      for (final word in words) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }

    final sortedEntries = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topWords = sortedEntries.take(limit).toList();

    if (topWords.isEmpty) {
      return [];
    }

    final maxCount = topWords.first.value;
    final minCount = topWords.last.value;
    final range = maxCount - minCount;

    return topWords.map((e) {
      final normalizedSize = range > 0
          ? 0.5 + (e.value - minCount) / range * 0.5
          : 1.0;
      return WordFrequency(
        word: e.key,
        count: e.value,
        normalizedSize: normalizedSize,
      );
    }).toList();
  }

  List<CategoryDistribution> _calculateCategoryDistribution(
    List<Entry> entries,
    List<Category> categories,
  ) {
    final categoryCounts = <String, int>{};

    for (final entry in entries) {
      categoryCounts[entry.categoryId] = (categoryCounts[entry.categoryId] ?? 0) + 1;
    }

    final categoryMap = {for (final c in categories) c.id: c};
    final total = entries.length;

    final distributions = categoryCounts.entries.map((e) {
      final category = categoryMap[e.key];
      return CategoryDistribution(
        categoryId: e.key,
        categoryName: category?.name ?? 'Unknown',
        emoji: category?.emoji,
        entryCount: e.value,
        percentage: e.value / total * 100,
      );
    }).toList();

    distributions.sort((a, b) => b.entryCount.compareTo(a.entryCount));
    return distributions;
  }

  Map<String, int> _calculateEntriesByMonth(List<Entry> entries) {
    final monthCounts = <String, int>{};
    final formatter = DateFormat('yyyy-MM');

    for (final entry in entries) {
      final monthKey = formatter.format(entry.createdAt);
      monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;
    }

    return monthCounts;
  }
}
