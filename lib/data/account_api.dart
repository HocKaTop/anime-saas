import '../domain/auth_user.dart';
import 'api_client.dart';
import 'result.dart';

class MalConnection {
  const MalConnection({
    required this.connected,
    this.username,
    this.lastSyncAt,
    this.lastSyncError,
  });

  final bool connected;
  final String? username;
  final DateTime? lastSyncAt;
  final String? lastSyncError;

  factory MalConnection.fromJson(Map<String, dynamic> json) {
    return MalConnection(
      connected: json['connected'] as bool,
      username: json['malUsername'] as String?,
      lastSyncAt: DateTime.tryParse(
        json['lastSyncAt'] as String? ?? '',
      ),
      lastSyncError: json['lastSyncError'] as String?,
    );
  }
}

class AccountApi {
  AccountApi(this._client);

  final ApiClient _client;

  Future<Result<AuthUser>> updateNickname(String nickname) {
    final value = nickname.trim();

    return _client.patch<AuthUser>(
      '/api/users/me',
      body: {
        'nickname': value.isEmpty ? null : value,
      },
      decode: (json) {
        final response = json as Map<String, dynamic>;

        return AuthUser.fromJson(
          response['user'] as Map<String, dynamic>,
        );
      },
    );
  }

  Future<Result<void>> changePassword(
    String current,
    String next,
  ) {
    return _client.patch<void>(
      '/api/users/me/password',
      body: {
        'currentPassword': current,
        'newPassword': next,
      },
      unauthorizedMessage: (json) {
        if (json is Map<String, dynamic> &&
            json['code'] == 'UNAUTHORIZED' &&
            json['message'] == 'Current password is incorrect') {
          return 'Неверный текущий пароль';
        }

        return null;
      },
      decode: (json) {
        final response = json as Map<String, dynamic>;

        if (response['success'] != true) {
          throw const FormatException(
            'Смена пароля не подтверждена',
          );
        }
      },
    );
  }

  Future<Result<MalConnection>> malStatus() {
    return _client.get<MalConnection>(
      '/api/integrations/mal/status',
      decode: (json) {
        final response = json as Map<String, dynamic>;

        return MalConnection.fromJson(
          response['connection'] as Map<String, dynamic>,
        );
      },
    );
  }

  Future<Result<Uri>> connectMal() {
    return _client.get<Uri>(
      '/api/integrations/mal/connect?redirectPath=%2Faccount',
      decode: (json) {
        final response = json as Map<String, dynamic>;
        final url = Uri.parse(
          response['authorizationUrl'] as String,
        );

        if (url.scheme != 'https' ||
            url.host != 'myanimelist.net') {
          throw const FormatException(
            'Некорректная ссылка MAL',
          );
        }

        return url;
      },
    );
  }

  Future<Result<void>> disconnectMal() {
    return _client.delete<void>(
      '/api/integrations/mal/connection',
      decode: (json) {
        final response = json as Map<String, dynamic>;

        if (response['disconnected'] != true) {
          throw const FormatException(
            'Отключение MAL не подтверждено',
          );
        }
      },
    );
  }
}