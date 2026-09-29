import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../domain/episode.dart';
import '../repositories/episode_repository.dart';

class EpisodeModel extends ChangeNotifier {
  final EpisodeRepository _repository;

  EpisodeModel(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Episode> _episodes = const [];

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Episode> get episodes =>
      List.unmodifiable(_episodes);

  Episode? byId(String id) {
    for (final episode in _episodes) {
      if (episode.id == id) {
        return episode;
      }
    }

    return null;
  }

  List<Episode> forTitle(String slug) {
    return _episodes
        .where(
          (episode) => episode.titleSlug == slug,
        )
        .toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _episodes = value;

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;

    notifyListeners();
  }
}