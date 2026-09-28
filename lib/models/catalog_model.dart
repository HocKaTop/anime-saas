import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../domain/anime_title.dart';
import '../repositories/title_repository.dart';

class CatalogModel extends ChangeNotifier {
  final TitleRepository _repository;

  CatalogModel(this._repository);

  bool _isLoading = false;
  String? _error;
  List<AnimeTitle> _titles = const [];

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<AnimeTitle> get titles =>
      List.unmodifiable(_titles);

  AnimeTitle? bySlug(String slug) {
    for (final title in _titles) {
      if (title.slug == slug) {
        return title;
      }
    }

    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _titles = value;

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;

    notifyListeners();
  }
}