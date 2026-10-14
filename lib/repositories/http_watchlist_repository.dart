import '../data/api_client.dart';
import '../data/result.dart';
import 'watchlist_repository.dart';

class HttpWatchlistRepository implements WatchlistRepository {
  HttpWatchlistRepository(this._client);

  final ApiClient _client;

  @override
  Future<Result<List<String>>> fetchAll() {
    return _client.get<List<String>>(
      '/api/watchlist',
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final items = response['items'] as List;

        return items.map((item) {
          final entry = item as Map<String, dynamic>;
          return entry['titleId'] as String;
        }).toList();
      },
    );
  }

  @override
  Future<Result<void>> add(String titleId) {
    return _client.post<void>(
      '/api/watchlist/titles/${Uri.encodeComponent(titleId)}',
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final item = response['item'] as Map<String, dynamic>;

        if (item['titleId'] as String != titleId) {
          throw const FormatException(
            'Сервер вернул закладку другого тайтла',
          );
        }
      },
    );
  }

  @override
  Future<Result<void>> remove(String titleId) {
    return _client.delete<void>(
      '/api/watchlist/titles/${Uri.encodeComponent(titleId)}',
      decode: (json) {
        // Поддерживаем также успешный ответ без тела: 204.
        if (json == null) return;

        final response = json as Map<String, dynamic>;
        final removed = response['removed'] as bool;

        if (!removed) {
          throw const FormatException(
            'Сервер не подтвердил удаление закладки',
          );
        }
      },
    );
  }
}