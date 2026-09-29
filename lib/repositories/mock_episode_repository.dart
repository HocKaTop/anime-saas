import '../data/mock_data.dart';
import '../data/result.dart';
import '../domain/episode.dart';
import 'episode_repository.dart';

class MockEpisodeRepository implements EpisodeRepository {
  final List<Episode> _episodes = List.of(mockEpisodes);

  bool simulateError = false;

  static const _latency = Duration(
    milliseconds: 800,
  );

  static const _networkError =
      'Сервер не отвечает — повторите попытку';

  @override
  Future<Result<List<Episode>>> fetchAll() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    return Ok(
      List.unmodifiable(_episodes),
    );
  }

  @override
  Future<Result<Episode>> fetchById(
    String id,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    for (final episode in _episodes) {
      if (episode.id == id) {
        return Ok(episode);
      }
    }

    return const Err('Эпизод не найден');
  }

  @override
  Future<Result<List<Episode>>> fetchByTitle(
    String titleSlug,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final result = _episodes
        .where(
          (episode) => episode.titleSlug == titleSlug,
        )
        .toList();

    return Ok(result);
  }
}