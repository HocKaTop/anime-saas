import 'api_client.dart';
import 'result.dart';
import '../domain/anime_title.dart';

class SearchApi {
  SearchApi(this._client);

  final ApiClient _client;

  Future<Result<List<AnimeTitle>>> search(String query){
    final params = Uri(
        queryParameters: {"q": query.trim()},
    ).query;

    return _client.get<List<AnimeTitle>>(
        '/api/search/titles?$params',
        authenticated: false,
        decode:(json){
            final response = json as Map<String,dynamic>;
            final items = response['items']as List;
            return items.map((item){
                return AnimeTitle.fromJson(
                    item as Map<String,dynamic>,
                );
            }).toList();
        },
    );
  }
}