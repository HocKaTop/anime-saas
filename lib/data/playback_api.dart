import 'api_client.dart';
import 'result.dart';

class PlaybackApi {
  PlaybackApi(this._client);

  final ApiClient _client;

  Future<Result<Uri>> getManifest(String episodeId) async {
    final version = _client.tokens.sessionVersion;

    final result = await _client.get<Uri?>(
      '/api/playback/episodes/'
      '${Uri.encodeComponent(episodeId)}/manifest',
      decode: (json) {
        final data = json as Map<String, dynamic>;

        if (data['status'] != 'ready' ||
            data['manifest'] == null) {
          return null;
        }

        final manifest =
            data['manifest'] as Map<String, dynamic>;
        final address = manifest['url'] as String;

        if (address.trim().isEmpty) {
          throw const FormatException('Empty URL');
        }

        final base = Uri.parse(_client.baseUrl);
        final url = base.resolve(address);

        if (url.scheme != base.scheme ||
            url.host != base.host ||
            url.port != base.port) {
          throw const FormatException('Unexpected origin');
        }

        return url;
      },
    );

    switch (result) {
      case Err(:final msg):
        return Err<Uri>(msg);

      case Ok(:final value):
        if (value == null) {
          return const Err<Uri>(
            'Видео ещё не готово к просмотру',
          );
        }

        return switch (
          await _client.accessToken(expectedSession: version)
        ) {
          Ok(value: final token) => Ok<Uri>(
              value.replace(
                queryParameters: {
                  ...value.queryParameters,
                  'access_token': token,
                },
              ),
            ),
          Err(:final msg) => Err<Uri>(msg),
        };
    }
  }
}