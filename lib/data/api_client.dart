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
  static const _changed =
      'Сессия изменилась — повторите действие';

  Future<Result<String>>? _refreshing;
  int? _refreshVersion;

  Future<Result<T>> get<T>(
    String path, {
    required T Function(Object?) decode,
    bool authenticated = true,
  }) {
    return _request(
      'GET',
      path,
      decode,
      authenticated: authenticated,
    );
  }

  Future<Result<T>> post<T>(
    String path, {
    required T Function(Object?) decode,
    Map<String, Object?>? body,
    bool authenticated = true,
  }) {
    return _request(
      'POST',
      path,
      decode,
      body: body,
      authenticated: authenticated,
    );
  }

  Future<Result<T>> delete<T>(
    String path, {
    required T Function(Object?) decode,
    bool authenticated = true,
  }) {
    return _request(
      'DELETE',
      path,
      decode,
      authenticated: authenticated,
    );
  }

  Future<Result<String>> accessToken({
    int? expectedSession,
    String? rejectedToken,
  }) async {
    final version = expectedSession ?? tokens.sessionVersion;
    final session = await tokens.snapshot();

    if (session.version != version) {
      return const Err(_changed);
    }

    // Все запросы одной сессии ждут общий refresh.
    final pending = _refreshing;

    if (pending != null) {
      if (_refreshVersion == version) {
        return pending;
      }

      await pending;

      return accessToken(
        expectedSession: version,
        rejectedToken: rejectedToken,
      );
    }

    final token = session.token;

    if (token != null &&
        token.isNotEmpty &&
        token != rejectedToken &&
        !_expiresSoon(token)) {
      return Ok(token);
    }

    if (session.cookie == null || session.cookie!.isEmpty) {
      await _expire(version, token);

      return const Err(
        'Сессия истекла — войдите снова',
      );
    }

    final future = _refresh(session);
    _refreshing = future;
    _refreshVersion = version;

    try {
      return await future;
    } finally {
      if (identical(_refreshing, future)) {
        _refreshing = null;
        _refreshVersion = null;
      }
    }
  }

  bool _expiresSoon(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return true;
      }

      final json = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]),
          ),
        ),
      ) as Map<String, dynamic>;

      final exp = json['exp'] as num;

      // Читаем срок для планирования refresh.
      // Подлинность JWT проверяет сервер.
      return DateTime.now().millisecondsSinceEpoch + 60000 >=
          exp * 1000;
    } on FormatException {
      return true;
    } on TypeError {
      return true;
    }
  }

  Future<Result<String>> _refresh(
    StoredSession session,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Accept': 'application/json',
          'Cookie': session.cookie!,
        },
      ).timeout(_timeout);

      if (tokens.sessionVersion != session.version) {
        return const Err(_changed);
      }

      if (response.statusCode == 401) {
        await _expire(session.version, session.token);

        return const Err(
          'Сессия истекла — войдите снова',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return Err(apiMessage(response));
      }

      final json = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final token = json['accessToken'] as String;
      final cookie = response.headers['set-cookie']
          ?.split(';')
          .first
          .trim();

      if (token.isEmpty || cookie == null || cookie.isEmpty) {
        return const Err(
          'Сервер не вернул токен или refresh cookie',
        );
      }

      final saved = await tokens.replaceAfterRefresh(
        session,
        token,
        cookie,
      );

      return saved ? Ok(token) : const Err(_changed);
    } on SocketException {
      return const Err('Не удалось подключиться к серверу');
    } on http.ClientException {
      return const Err('Ошибка соединения с сервером');
    } on TimeoutException {
      return const Err(
        'Сервер не отвечает — повторите попытку',
      );
    } on FormatException {
      return const Err('Сервер вернул некорректный ответ');
    } on TypeError {
      return const Err(
        'Ответ сервера не соответствует ожидаемому формату',
      );
    }
  }

  Future<Result<T>> _request<T>(
    String method,
    String path,
    T Function(Object?) decode, {
    Map<String, Object?>? body,
    required bool authenticated,
  }) async {
    final version = tokens.sessionVersion;

    try {
      String? token;

      if (authenticated) {
        switch (await accessToken(expectedSession: version)) {
          case Ok(:final value):
            token = value;

          case Err(:final msg):
            return Err<T>(msg);
        }
      }

      for (var attempt = 0; attempt < 2; attempt++) {
        if (authenticated &&
            tokens.sessionVersion != version) {
          return Err<T>(_changed);
        }

        final request = http.Request(
          method,
          Uri.parse('$baseUrl$path'),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (authenticated)
            'Authorization': 'Bearer $token',
        });

        if (body != null) {
          request.headers['Content-Type'] = 'application/json';
          request.body = jsonEncode(body);
        }

        final response = await _send(request).timeout(_timeout);

        if (authenticated &&
            tokens.sessionVersion != version) {
          return Err<T>(_changed);
        }

        if (authenticated && response.statusCode == 401) {
          if (attempt == 1) {
            await _expire(version, token);

            return Err<T>(
              'Сессия истекла — войдите снова',
            );
          }

          switch (
            await accessToken(
              expectedSession: version,
              rejectedToken: token,
            )
          ) {
            case Ok(:final value):
              token = value;

            case Err(:final msg):
              return Err<T>(msg);
          }

          continue;
        }

        if (response.statusCode < 200 ||
            response.statusCode >= 300) {
          return Err<T>(apiMessage(response));
        }

        final Object? json = response.statusCode == 204
            ? null
            : jsonDecode(utf8.decode(response.bodyBytes));

        return Ok<T>(decode(json));
      }

      return Err<T>('Не удалось выполнить запрос');
    } on SocketException {
      return Err<T>('Не удалось подключиться к серверу');
    } on http.ClientException {
      return Err<T>('Ошибка соединения с сервером');
    } on TimeoutException {
      return Err<T>(
        'Сервер не отвечает — повторите попытку',
      );
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

  Future<void> _expire(int version, String? token) async {
    final cleared = await tokens.clearIfCurrent(version, token);

    if (cleared && tokens.sessionVersion == version + 1) {
      onUnauthorized();
    }
  }
}