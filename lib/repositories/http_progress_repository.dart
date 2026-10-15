import '../data/api_client.dart';
import '../data/result.dart';
import '../domain/watch_progress.dart';
import 'progress_repository.dart';

class HttpProgressRepository implements ProgressRepository {
  HttpProgressRepository(this._client);

  final ApiClient _client;

  @override
  Future<Result<WatchProgress?>> fetchByEpisode(
    String episodeId,
  ) {
    return _client.get<WatchProgress?>(
      '/api/progress/episodes/${Uri.encodeComponent(episodeId)}',
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final progress = response['progress'];

        if (progress == null) return null;

        return WatchProgress.fromJson(
          progress as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<Result<WatchProgress>> save(WatchProgress progress) {
    return _client.post<WatchProgress>(
      '/api/progress/episodes/'
      '${Uri.encodeComponent(progress.episodeId)}',
      body: progress.toJson(),
      decode: (json) {
        final response = json as Map<String, dynamic>;

        return WatchProgress.fromJson(
          response['progress'] as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<Result<List<WatchProgress>>> fetchContinueWatching() {
    return _fetchList('/api/progress/continue-watching');
  }

  @override
  Future<Result<List<WatchProgress>>> fetchCompleted() {
    return _fetchList('/api/progress/completed');
  }

  Future<Result<List<WatchProgress>>> _fetchList(String path) {
    return _client.get<List<WatchProgress>>(
      path,
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final items = response['items'] as List;

        return items.map((item) {
          final entry = item as Map<String, dynamic>;

          return WatchProgress.fromJson(
            entry['progress'] as Map<String, dynamic>,
          );
        }).toList();
      },
    );
  }
}