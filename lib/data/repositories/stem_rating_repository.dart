import 'package:uuid/uuid.dart';

import '../datasources/local/stem_rating_datasource.dart';
import '../models/stem_rating.dart';

class StemRatingRepository {
  final StemRatingDatasource _datasource;
  final Uuid _uuid;

  StemRatingRepository({
    required StemRatingDatasource datasource,
    Uuid? uuid,
  })  : _datasource = datasource,
        _uuid = uuid ?? const Uuid();

  Future<StemRating> rateStem({
    required String stemId,
    required StemRatingValue rating,
    String? entryId,
  }) async {
    final existingRating = await _datasource.getRatingByStemId(stemId);

    if (existingRating != null) {
      final updated = existingRating.copyWith(
        rating: rating,
        entryId: entryId ?? existingRating.entryId,
        ratedAt: DateTime.now(),
      );
      await _datasource.updateRating(updated);
      return updated;
    }

    final newRating = StemRating(
      id: _uuid.v4(),
      stemId: stemId,
      rating: rating,
      entryId: entryId,
      ratedAt: DateTime.now(),
    );
    await _datasource.insertRating(newRating);
    return newRating;
  }

  Future<StemRating?> getRatingForStem(String stemId) {
    return _datasource.getRatingByStemId(stemId);
  }

  Future<StemRating?> getRatingForEntry(String entryId) {
    return _datasource.getRatingByEntryId(entryId);
  }

  Future<List<StemRating>> getAllRatings() {
    return _datasource.getAllRatings();
  }

  Future<List<StemRating>> getPositiveRatings() {
    return _datasource.getRatingsByValue(StemRatingValue.positive);
  }

  Future<List<StemRating>> getNegativeRatings() {
    return _datasource.getRatingsByValue(StemRatingValue.negative);
  }

  Future<void> deleteRating(String id) {
    return _datasource.deleteRating(id);
  }
}
