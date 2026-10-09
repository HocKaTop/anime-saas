import "dart:convert";
import "package:http/http.dart" as http;

String apiMessage(
  http.Response response, {
  bool authentication = false,
  }) {
    try{
      final json = jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String,dynamic>;

      final code = json['code'] as String;

      return switch (code) {
      'VALIDATION_FAILED' =>
        'Проверьте введённые данные',
      'UNAUTHORIZED' => authentication
          ? 'Неверный email или пароль'
          : 'Сессия истекла — войдите снова',
      'FORBIDDEN' =>
        'Недостаточно прав для этого действия',
      'NOT_FOUND' =>
        'Запрошенные данные не найдены',
      'CONFLICT' => authentication
          ? 'Аккаунт с этим email уже существует'
          : 'Данные конфликтуют с существующей записью',
      'RATE_LIMITED' =>
        'Слишком много запросов — попробуйте позже',
      'UPSTREAM_UNAVAILABLE' =>
        'Сервис временно недоступен',
      _ => 'Ошибка сервера (${response.statusCode})',
    };
    } on FormatException{
      return 'Ошибка сервера (${response.statusCode})';
    } on TypeError {
      return 'Ошибка сервера (${response.statusCode})';
    } 
  }