import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../domain/watch_progress.dart';
import '../repositories/progress_repository.dart';

class ProgressModel extends ChangeNotifier {
  final ProgressRepository _repository;

  ProgressModel(this._repository);

  bool _isLoading = false;
  String? _error;

  final Map<String, WatchProgress> _progress = {};

  bool get isLoading => _isLoading;

  String? get error => _error;

  WatchProgress? byEpisode(
    String episodeId,
  ) {
    return _progress[episodeId];
  }

  Future<void> loadEpisode(
    String episodeId,
  ) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    switch (
        await _repository.fetchByEpisode(episodeId)) {
      case Ok(:final value):
        if (value != null) {
          _progress[episodeId] = value;
        } else {
          _progress.remove(episodeId);
        }

      case Err(:final msg):
        _error = msg;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<String?> saveProgress(
    String episodeId,
    double value,
  ) async {
    final normalized =
        value.clamp(0.0, 1.0).toDouble();

    final draft = WatchProgress(
      episodeId: episodeId,
      progress: normalized,
    );

    switch (await _repository.save(draft)) {
      case Ok(:final value):
        _progress[episodeId] = value;

        notifyListeners();

        return null;

      case Err(:final msg):
        return msg;
    }
  }
}