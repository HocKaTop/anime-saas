import '../data/api_client.dart';
import '../data/result.dart';
import '../domain/episode.dart';
import 'episode_repository.dart';

class HttpEpisodeRepository implements EpisodeRepository {
  HttpEpisodeRepository(this._client);

  final ApiClient _client;

  // Контекст серий, полученных из карточек тайтлов.
  final Map<String, Episode> _knownEpisodes = {};

  @override
  Future<Result<List<Episode>>> fetchByTitle(
    String titleSlug,
  ) async {
    final result = await _client.get<List<Episode>>(
      '/api/titles/${Uri.encodeComponent(titleSlug)}',
      authenticated: false,
      decode: (json) {
        final title = json as Map<String, dynamic>;
        final seasons = title['seasons'] as List;
        final episodes = <Episode>[];

        for (final item in seasons) {
          final season = item as Map<String, dynamic>;
          final seasonNumber = (season['number'] as num).toInt();
          final items = season['episodes'] as List;

          for (final item in items) {
            episodes.add(
              Episode.fromJson(
                item as Map<String, dynamic>,
                titleSlug: titleSlug,
                seasonNumber: seasonNumber,
              ),
            );
          }
        }

        episodes.sort((a, b) {
          final seasonOrder =
              a.seasonNumber.compareTo(b.seasonNumber);

          return seasonOrder == 0
              ? a.number.compareTo(b.number)
              : seasonOrder;
        });

        return episodes;
      },
    );

    if (result case Ok(:final value)) {
      _knownEpisodes.removeWhere(
        (_, episode) => episode.titleSlug == titleSlug,
      );

      for (final episode in value) {
        _knownEpisodes[episode.id] = episode;
      }
    }

    return result;
  }

  @override
  Future<Result<Episode>> fetchById(String id) {
    final known = _knownEpisodes[id];

    if (known == null) {
      return Future.value(
        const Err<Episode>(
          'Сначала откройте карточку тайтла с этой серией',
        ),
      );
    }

    return _client.get<Episode>(
      '/api/episodes/${Uri.encodeComponent(id)}',
      authenticated: false,
      decode: (json) {
        return Episode.fromJson(
          json as Map<String, dynamic>,
          titleSlug: known.titleSlug,
          seasonNumber: known.seasonNumber,
        );
      },
    );
  }

  @override
  Future<Result<List<Episode>>> fetchAll() async {
    return const Err<List<Episode>>(
      'Для загрузки серий необходимо выбрать тайтл',
    );
  }
}