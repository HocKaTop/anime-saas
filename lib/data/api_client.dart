import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class ApiClient {
  ApiClient(
    this.baseUrl,
    this.tokens, {
    required this.onUnauthorized,
  });

  final String baseUrl;
  final TokenStore tokens;
  final void Function() onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  bool _expiringSession = false;

  Future<Result<T>> get<T>(
    String path, {
    required T Function(Object? json) decode,
    bool authenticated = true,
  }) async {
    try {
      final token = authenticated ? await tokens.read() : null;

      if (authenticated &&
          (token == null || token.trim().isEmpty)) {
        await _expireSession(token);

        return Err<T>('Войдите в аккаунт');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Accept': 'application/json',
              if (authenticated) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (authenticated && response.statusCode == 401) {
        await _expireSession(token);

        return Err<T>('Сессия истекла — войдите снова');
      }

      if (response.statusCode != 200) {
        return Err<T>(apiMessage(response));
      }

      final json = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      return Ok<T>(decode(json));
    } on SocketException {
      return Err<T>('Не удалось подключиться к серверу');
    } on http.ClientException {
      return Err<T>('Ошибка соединения с сервером');
    } on TimeoutException {
      return Err<T>('Сервер не отвечает — повторите попытку');
    } on FormatException {
      return Err<T>('Сервер вернул некорректный ответ');
    } on TypeError {
      return Err<T>(
        'Ответ сервера не соответствует ожидаемому формату',
      );
    }
  }

  Future<void> _expireSession(String? usedToken) async {
    if (_expiringSession) return;

    _expiringSession = true;

    try {
      // Запоздалый ответ старого запроса не должен
      // очищать токен, полученный после нового входа.
      final currentToken = await tokens.read();

      if (currentToken != usedToken) return;

      await tokens.clear();
      onUnauthorized();
    } finally {
      _expiringSession = false;
    }
  }
}