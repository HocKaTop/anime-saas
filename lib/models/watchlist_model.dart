import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../repositories/watchlist_repository.dart';

class WatchlistModel extends ChangeNotifier {
  final WatchlistRepository _repository;

  WatchlistModel(this._repository);

  bool _isLoading = false;
  String? _error;
  Set<String> _titleIds = {};

  bool get isLoading => _isLoading;

  String? get error => _error;

  Set<String> get titleIds =>
      Set.unmodifiable(_titleIds);

  int get count => _titleIds.length;

  bool contains(String titleId) {
    return _titleIds.contains(titleId);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _titleIds = value.toSet();

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<String?> add(String titleId) async {
    switch (await _repository.add(titleId)) {
      case Ok():
        _titleIds = {
          ..._titleIds,
          titleId,
        };

        notifyListeners();

        return null;

      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(
    String titleId,
  ) async {
    switch (await _repository.remove(titleId)) {
      case Ok():
        _titleIds = {
          ..._titleIds,
        }..remove(titleId);

        notifyListeners();

        return null;

      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> toggle(
    String titleId,
  ) {
    if (contains(titleId)) {
      return remove(titleId);
    }

    return add(titleId);
  }
}