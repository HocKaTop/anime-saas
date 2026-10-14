import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../repositories/watchlist_repository.dart';

class WatchlistModel extends ChangeNotifier {
  WatchlistModel(this._repository);

  final WatchlistRepository _repository;

  bool _isLoading = false;
  String? _error;
  Set<String> _titleIds = {};
  int _revision = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get titleIds => Set.unmodifiable(_titleIds);
  int get count => _titleIds.length;

  bool contains(String titleId) => _titleIds.contains(titleId);

  Future<void> load() async {
    if (_isLoading) return;

    final revision = ++_revision;

    _isLoading = true;
    _error = null;
    _titleIds = {};
    notifyListeners();

    final result = await _repository.fetchAll();

    if (revision != _revision) return;

    switch (result) {
      case Ok(:final value):
        _titleIds = value.toSet();

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> add(String titleId) {
    return _change(titleId, adding: true);
  }

  Future<String?> remove(String titleId) {
    return _change(titleId, adding: false);
  }

  Future<String?> toggle(String titleId) {
    return contains(titleId) ? remove(titleId) : add(titleId);
  }

  Future<String?> _change(
    String titleId, {
    required bool adding,
  }) async {
    if (_isLoading) {
      return 'Дождитесь завершения предыдущего запроса';
    }

    final revision = ++_revision;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = adding
          ? await _repository.add(titleId)
          : await _repository.remove(titleId);

      if (revision != _revision) {
        return 'Сессия изменилась — повторите действие';
      }

      switch (result) {
        case Ok():
          if (adding) {
            _titleIds.add(titleId);
          } else {
            _titleIds.remove(titleId);
          }
          return null;

        case Err(:final msg):
          _error = msg;
          return msg;
      }
    } finally {
      if (revision == _revision) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _revision++;
    _titleIds = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}