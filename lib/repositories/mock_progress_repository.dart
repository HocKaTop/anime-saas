import '../data/mock_data.dart';
import '../data/result.dart';
import '../domain/watch_progress.dart';
import 'progress_repository.dart';

class MockProgressRepository
    implements ProgressRepository {
  final Map<String, WatchProgress> _progress = {
    for (final item in mockProgress)
      item.episodeId: item,
  };

  bool simulateError = false;

  static const _latency = Duration(
    milliseconds: 800,
  );

  static const _networkError =
      'Сервер не отвечает — повторите попытку';

  @override
  Future<Result<WatchProgress?>> fetchByEpisode(
    String episodeId,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    return Ok(_progress[episodeId]);
  }

  @override
  Future<Result<WatchProgress>> save(
    WatchProgress progress,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    _progress[progress.episodeId] = progress;

    return Ok(progress);
  }

  @override
  Future<Result<List<WatchProgress>>>
      fetchContinueWatching() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final result = _progress.values
        .where(
          (item) =>
              item.progress > 0 &&
              item.progress < 1,
        )
        .toList();

    return Ok(result);
  }

  @override
  Future<Result<List<WatchProgress>>>
      fetchCompleted() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final result = _progress.values
        .where((item) => item.completed)
        .toList();

    return Ok(result);
  }
}