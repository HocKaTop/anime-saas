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
  }) {
    return _request<T>(
      'GET',
      path,
      decode: decode,
      authenticated: authenticated,
    );
  }

  Future<Result<T>> post<T>(
    String path, {
    required T Function(Object? json) decode,
    Map<String, Object?>? body,
    bool authenticated = true,
  }) {
    return _request<T>(
      'POST',
      path,
      decode: decode,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<Result<T>> delete<T>(
    String path, {
    required T Function(Object? json) decode,
    bool authenticated = true,
  }) {
    return _request<T>(
      'DELETE',
      path,
      decode: decode,
      authenticated: authenticated,
    );
  }

  Future<Result<T>> _request<T>(
    String method,
    String path, {
    required T Function(Object? json) decode,
    Map<String, Object?>? body,
    required bool authenticated,
  }) async {
    try {
      final token = authenticated ? await tokens.read() : null;

      if (authenticated &&
          (token == null || token.trim().isEmpty)) {
        await _expireSession(token);
        return Err<T>('Войдите в аккаунт');
      }

      final request = http.Request(
        method,
        Uri.parse('$baseUrl$path'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (authenticated) 'Authorization': 'Bearer $token',
      });

      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }

      // Таймаут охватывает отправку и чтение ответа.
      final response = await _send(request).timeout(_timeout);

      // Ответ старого аккаунта не применяется к новой сессии.
      if (authenticated && await tokens.read() != token) {
        return Err<T>('Сессия изменилась — повторите действие');
      }

      if (authenticated && response.statusCode == 401) {
        await _expireSession(token);
        return Err<T>('Сессия истекла — войдите снова');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return Err<T>(apiMessage(response));
      }

      final Object? json = response.statusCode == 204
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));

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

  Future<http.Response> _send(http.Request request) async {
    final response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<void> _expireSession(String? usedToken) async {
    if (_expiringSession) return;

    _expiringSession = true;

    try {
      final currentToken = await tokens.read();

      if (currentToken != usedToken) return;

      await tokens.clear();
      onUnauthorized();
    } finally {
      _expiringSession = false;
    }
  }
}