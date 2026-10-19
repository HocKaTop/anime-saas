import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  const StoredSession(this.version, this.token, this.cookie);

  final int version;
  final String? token;
  final String? cookie;
}

class TokenStore {
  static const _tokenKey = 'auth_token';
  static const _cookieKey = 'auth_refresh_cookie';

  int _version = 0;
  Future<void> _pending = Future<void>.value();

  int get sessionVersion => _version;

  Future<T> _queue<T>(
    Future<T> Function(SharedPreferences) action,
  ) {
    final task = _pending.then((_) async {
      return action(await SharedPreferences.getInstance());
    });

    // Ошибка одной операции не блокирует следующие.
    // Сам task при этом сохраняет свою ошибку для вызывающего.
    _pending = task.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );

    return task;
  }

  Future<StoredSession> snapshot() async {
    while (true) {
      final pending = _pending;
      await pending;

      final prefs = await SharedPreferences.getInstance();

      if (!identical(pending, _pending)) {
        continue;
      }

      return StoredSession(
        _version,
        prefs.getString(_tokenKey),
        prefs.getString(_cookieKey),
      );
    }
  }

  Future<String?> read() async => (await snapshot()).token;

  Future<String?> readRefreshCookie() async =>
      (await snapshot()).cookie;

  Future<void> save(
    String token, {
    String? refreshCookie,
  }) {
    final version = ++_version;

    return _queue<void>((prefs) async {
      if (version != _version) {
        return;
      }

      await prefs.setString(_tokenKey, token);

      if (refreshCookie == null) {
        await prefs.remove(_cookieKey);
      } else {
        await prefs.setString(_cookieKey, refreshCookie);
      }
    });
  }

  Future<bool> replaceAfterRefresh(
    StoredSession previous,
    String token,
    String cookie,
  ) {
    return _queue<bool>((prefs) async {
      if (_version != previous.version ||
          prefs.getString(_cookieKey) != previous.cookie) {
        return false;
      }

      await prefs.setString(_tokenKey, token);
      await prefs.setString(_cookieKey, cookie);

      return _version == previous.version;
    });
  }

  Future<bool> clearIfCurrent(int version, String? token) {
    return _queue<bool>((prefs) async {
      if (_version != version ||
          prefs.getString(_tokenKey) != token) {
        return false;
      }

      _version++;

      await prefs.remove(_tokenKey);
      await prefs.remove(_cookieKey);

      return true;
    });
  }

  Future<void> clear() {
    _version++;

    return _queue<void>((prefs) async {
      await prefs.remove(_tokenKey);
      await prefs.remove(_cookieKey);
    });
  }
}
