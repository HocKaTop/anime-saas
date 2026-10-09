import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _tokenKey = 'auth_token';
  static const _cookieKey = 'auth_refresh_cookie';

  Future<String?> read() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> readRefreshCookie() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  Future<void> save(
    String token, {
      String? refreshCookie,
    }) async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, token );

      if (refreshCookie == null){
        await prefs.remove(_cookieKey);
      }else{
        await prefs.setString(_cookieKey, refreshCookie);
      }
    }

    Future <void> clear() async{
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove (_cookieKey);
    } 
}