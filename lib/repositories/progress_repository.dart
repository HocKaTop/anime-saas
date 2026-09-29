import '../data/result.dart';
import '../domain/watch_progress.dart';

abstract class ProgressRepository {
  Future<Result<WatchProgress?>> fetchByEpisode(
    String episodeId,
  );

  Future<Result<WatchProgress>> save(
    WatchProgress progress,
  );

  Future<Result<List<WatchProgress>>>
      fetchContinueWatching();

  Future<Result<List<WatchProgress>>>
      fetchCompleted();
}