import '../data/result.dart';
import '../domain/anime_title.dart';

abstract class TitleRepository {
  Future<Result<List<AnimeTitle>>> fetchAll();

  Future<Result<AnimeTitle>> fetchBySlug(
    String slug,
  );

  Future<Result<AnimeTitle>> create(
    AnimeTitle title,
  );

  Future<Result<AnimeTitle>> update(
    AnimeTitle title,
  );

  Future<Result<void>> delete(
    String slug,
  );
}