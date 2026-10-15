import 'api_client.dart';
import 'result.dart';

class PlaybackApi {
  PlaybackApi(this._client);

  final ApiClient _client;

  Future<Result<Uri>> getManifest(String episodeId) async {
    final token = await _client.tokens.read();

    if (token == null || token.isEmpty) {
      return const Err<Uri>('Войдите в аккаунт');
    }

    final result = await _client.get<Uri?>(
      '/api/playback/episodes/'
      '${Uri.encodeComponent(episodeId)}/manifest',
      decode: (json) {
        final data = json as Map<String, dynamic>;

        if (data['status'] != 'ready' || data['manifest'] == null) {
          return null;
        }

        final manifest = data['manifest'] as Map<String, dynamic>;
        final address = manifest['url'] as String;

        if (address.trim().isEmpty) {
          throw const FormatException('Empty manifest URL');
        }

        final base = Uri.parse(_client.baseUrl);
        final url = base.resolve(address);

        // Передаём токен только своему API.
        if (url.scheme != base.scheme ||
            url.host != base.host ||
            url.port != base.port) {
          throw const FormatException('Unexpected manifest origin');
        }

        return url.replace(
          queryParameters: {
            ...url.queryParameters,
            'access_token': token,
          },
        );
      },
    );

    if (await _client.tokens.read() != token) {
      return const Err<Uri>('Сессия изменилась — откройте серию снова');
    }

    return switch (result) {
      Ok(:final value) => value == null
          ? const Err<Uri>('Видео ещё не готово к просмотру')
          : Ok<Uri>(value),
      Err(:final msg) => Err<Uri>(msg),
    };
  }
}