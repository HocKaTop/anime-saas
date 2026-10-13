import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../domain/episode.dart';
import '../repositories/episode_repository.dart';

class EpisodeModel extends ChangeNotifier {
  EpisodeModel(this._repository);

  final EpisodeRepository _repository;

  bool _isLoading = false;
  String? _error;
  String? _titleSlug;
  List<Episode> _episodes = const [];
  int _revision = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get titleSlug => _titleSlug;

  List<Episode> get episodes => List.unmodifiable(_episodes);

  Episode? byId(String id) {
    for (final episode in _episodes) {
      if (episode.id == id) return episode;
    }

    return null;
  }

  List<Episode> forTitle(String slug) {
    return _episodes
        .where((episode) => episode.titleSlug == slug)
        .toList();
  }

  Future<void> load({String? titleSlug}) async {
    final slug = titleSlug ?? _titleSlug;

    if (slug == null || slug.isEmpty) {
      _error = 'Выберите тайтл для загрузки серий';
      notifyListeners();
      return;
    }

    final revision = ++_revision;

    _titleSlug = slug;
    _isLoading = true;
    _error = null;
    _episodes = const [];
    notifyListeners();

    final result = await _repository.fetchByTitle(slug);

    // Ответ предыдущего тайтла не заменяет новый.
    if (revision != _revision) return;

    switch (result) {
      case Ok(:final value):
        _episodes = value;

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;
    notifyListeners();
  }
}