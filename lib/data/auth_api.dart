import "dart:async";
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;
  static const _timeout = Duration(seconds: 8);

  Future<Result<void>> login(
    String email,
    String password,
  ){
    return _post('/api/auth/login',{
      'email':email.trim(),
      'password':password,
    });
  }

  Future<Result<void>> register(
    String email,
    String password,
  ){
    return _post('/api/auth/register',{
      'email':email.trim(),
      'password':password,
    });
  }

  Future<Result<void>> _post(
    String path,
    Map<String,String> body,
  ) async {
    try{
      final response = await http
      .post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type':"application/json",
          'Accept':"application/json",
        },
        body: jsonEncode(body),
      ).timeout(_timeout);

      //HTTP ошибка, если запрос дошел, но отклонен сервером
      if(response.statusCode != 200 && response.statusCode!=201){
        return Err<void>(
          apiMessage(response, authentication: true),
        );
      }

      //Проверка формата успешного ответа
      final json =
        jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String,dynamic>;

      final token = json['accessToken'] as String;

      if(token.trim().isEmpty){
        return const Err<void>(
          'Сервер вернул пустой токен'
        );
      }
      //Для отправки рефреш куки
      final setCookie = response.headers['set-cookie'];
      final refreshCookie = setCookie?.split(";").first.trim();

      await tokens.save(
        token,
        refreshCookie: refreshCookie,
      );

      return const Ok<void>(null);
    } on SocketException{
      return const Err<void>("Не удалось подключиться к серверу");
    } on http.ClientException{
      return const Err<void>("Ошибка соединения с сервером");
    } on TimeoutException{
      return const Err<void>("Сервер не отвечает. Повторите попытку позже");
    }on FormatException{
      return const Err<void>("Сервер вернул некорретный ответ");
    } on TypeError{
      return const Err<void>("Ответ сервера не соответствует ожидаемому формату");
    }
  }
}