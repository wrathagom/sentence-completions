import '../datasources/local/stem_local_datasource.dart';
import '../datasources/remote/stems_remote_datasource.dart';
import '../models/category.dart';
import '../models/stem.dart';

class StemRepository {
  final StemLocalDatasource _localDatasource;
  final StemsRemoteDatasource _remoteDatasource;

  StemRepository({
    required StemLocalDatasource localDatasource,
    required StemsRemoteDatasource remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  Future<void> syncStems() async {
    final data = await _remoteDatasource.fetchStems();
    await _localDatasource.insertCategories(data.categories);
    await _localDatasource.insertStems(data.stems);
  }

  Future<bool> hasStems() async {
    final count = await _localDatasource.getStemCount();
    return count > 0;
  }

  Future<List<Stem>> getAllStems() {
    return _localDatasource.getAllStems();
  }

  Future<List<Stem>> getStemsByCategory(String categoryId) {
    return _localDatasource.getStemsByCategory(categoryId);
  }

  Future<Stem?> getStemById(String id) {
    return _localDatasource.getStemById(id);
  }

  Future<Stem?> getRandomStem({Set<String>? excludeStemIds}) {
    return _localDatasource.getRandomStem(excludeStemIds: excludeStemIds);
  }

  Future<Stem?> getRandomStemByCategory(
    String categoryId, {
    Set<String>? excludeStemIds,
  }) {
    return _localDatasource.getRandomStemByCategory(
      categoryId,
      excludeStemIds: excludeStemIds,
    );
  }

  Future<List<Category>> getAllCategories() {
    return _localDatasource.getAllCategories();
  }

  Future<Category?> getCategoryById(String id) {
    return _localDatasource.getCategoryById(id);
  }

  Future<List<Stem>> getStemsByKeywords({
    required List<String> keywords,
    required String excludeStemId,
    int limit = 5,
  }) {
    return _localDatasource.getStemsByKeywords(
      keywords: keywords,
      excludeStemId: excludeStemId,
      limit: limit,
    );
  }

  Future<List<Stem>> getRandomStems({
    required String excludeStemId,
    int limit = 3,
  }) {
    return _localDatasource.getRandomStems(
      excludeStemId: excludeStemId,
      limit: limit,
    );
  }
}
