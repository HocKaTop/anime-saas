import '../data/mock_data.dart';
import '../data/result.dart';
import '../domain/anime_title.dart';
import 'title_repository.dart';

class MockTitleRepository implements TitleRepository {
  final List<AnimeTitle> _titles = List.of(mockTitles);

  bool simulateError = false;

  static const _latency = Duration(
    milliseconds: 800,
  );

  static const _networkError =
      'Сервер не отвечает — повторите попытку';

  @override
  Future<Result<List<AnimeTitle>>> fetchAll() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    return Ok(
      List.unmodifiable(_titles),
    );
  }

  @override
  Future<Result<AnimeTitle>> fetchBySlug(
    String slug,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    for (final title in _titles) {
      if (title.slug == slug) {
        return Ok(title);
      }
    }

    return const Err('Тайтл не найден');
  }

  @override
  Future<Result<AnimeTitle>> create(
    AnimeTitle title,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    _titles.add(title);

    return Ok(title);
  }

  @override
  Future<Result<AnimeTitle>> update(
    AnimeTitle title,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final index = _titles.indexWhere(
      (item) => item.slug == title.slug,
    );

    if (index == -1) {
      return const Err('Тайтл не найден');
    }

    _titles[index] = title;

    return Ok(title);
  }

  @override
  Future<Result<void>> delete(
    String slug,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final index = _titles.indexWhere(
      (item) => item.slug == slug,
    );

    if (index == -1) {
      return const Err('Тайтл не найден');
    }

    _titles.removeAt(index);

    return const Ok(null);
  }
}