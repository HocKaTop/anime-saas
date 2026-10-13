import '../data/api_client.dart';
import '../data/result.dart';
import '../domain/anime_title.dart';
import 'title_repository.dart';

class HttpTitleRepository implements TitleRepository {
  HttpTitleRepository(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<AnimeTitle>>> fetchAll() {
    return _client.get<List<AnimeTitle>>(
      '/api/titles',
      authenticated: false,
      decode: (json) {
        final items = json as List;

        return items.map((item) {
          return AnimeTitle.fromJson(
            item as Map<String, dynamic>,
          );
        }).toList();
      },
    );
  }

  @override
  Future<Result<AnimeTitle>> fetchBySlug(String slug) {
    return _client.get<AnimeTitle>(
      '/api/titles/${Uri.encodeComponent(slug)}',
      authenticated: false,
      decode: (json) {
        return AnimeTitle.fromJson(
          json as Map<String, dynamic>,
        );
      },
    );
  }

  @override
  Future<Result<AnimeTitle>> create(AnimeTitle title) async {
    return const Err<AnimeTitle>(
      'Создание тайтлов доступно в административной панели',
    );
  }

  @override
  Future<Result<AnimeTitle>> update(AnimeTitle title) async {
    return const Err<AnimeTitle>(
      'Редактирование тайтлов доступно в административной панели',
    );
  }

  @override
  Future<Result<void>> delete(String slug) async {
    return const Err<void>(
      'Удаление тайтлов недоступно в мобильном приложении',
    );
  }
}