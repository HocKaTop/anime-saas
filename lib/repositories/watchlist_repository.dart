import '../data/result.dart';

abstract class WatchlistRepository {
  Future<Result<List<String>>> fetchAll();

  Future<Result<void>> add(
    String titleId,
  );

  Future<Result<void>> remove(
    String titleId,
  );
}