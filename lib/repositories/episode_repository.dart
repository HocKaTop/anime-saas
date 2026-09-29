import '../data/result.dart';
import '../domain/episode.dart';

abstract class EpisodeRepository {
  Future<Result<List<Episode>>> fetchAll();

  Future<Result<Episode>> fetchById(
    String id,
  );

  Future<Result<List<Episode>>> fetchByTitle(
    String titleSlug,
  );
}