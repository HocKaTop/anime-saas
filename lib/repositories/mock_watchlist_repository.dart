import '../data/mock_data.dart';
import '../data/result.dart';
import 'watchlist_repository.dart';

class MockWatchlistRepository
    implements WatchlistRepository {
  final Set<String> _titleIds =
      Set.of(mockWatchlistTitleIds);

  bool simulateError = false;

  static const _latency = Duration(
    milliseconds: 800,
  );

  static const _networkError =
      'Сервер не отвечает — повторите попытку';

  @override
  Future<Result<List<String>>> fetchAll() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    return Ok(
      List.unmodifiable(_titleIds),
    );
  }

  @override
  Future<Result<void>> add(
    String titleId,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    _titleIds.add(titleId);

    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> remove(
    String titleId,
  ) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    _titleIds.remove(titleId);

    return const Ok<void>(null);
  }
}