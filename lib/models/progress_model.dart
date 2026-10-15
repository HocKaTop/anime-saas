import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../domain/watch_progress.dart';
import '../repositories/progress_repository.dart';

class ProgressModel extends ChangeNotifier {
  ProgressModel(this._repository);

  final ProgressRepository _repository;

  final Map<String, WatchProgress> _progress = {};
  final Map<String, int> _saveVersions = {};

  bool _isLoading = false;
  String? _error;

  int _sessionVersion = 0;
  int _loadVersion = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;

  WatchProgress? byEpisode(String episodeId) {
    return _progress[episodeId];
  }

  Future<void> loadEpisode(String episodeId) async {
    final sessionVersion = _sessionVersion;
    final loadVersion = ++_loadVersion;
    final saveVersion = _saveVersions[episodeId] ?? 0;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchByEpisode(episodeId);

    if (sessionVersion != _sessionVersion ||
        loadVersion != _loadVersion) {
      return;
    }

    // Старый GET не заменяет результат более нового сохранения.
    if (saveVersion == (_saveVersions[episodeId] ?? 0)) {
      switch (result) {
        case Ok(:final value):
          if (value == null) {
            _progress.remove(episodeId);
          } else {
            _progress[episodeId] = value;
          }

        case Err(:final msg):
          _error = msg;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> saveProgress(
    String episodeId,
    double value, {
    required int durationSec,
  }) {
    if (!value.isFinite || durationSec <= 0) {
      return Future.value('Некорректный прогресс просмотра');
    }

    final normalized = value.clamp(0.0, 1.0).toDouble();

    return savePosition(
      episodeId,
      positionSec: (normalized * durationSec).round(),
      durationSec: durationSec,
    );
  }

  Future<String?> savePosition(
    String episodeId, {
    required int positionSec,
    int? durationSec,
  }) async {
    if (positionSec < 0 ||
        (durationSec != null && durationSec <= 0)) {
      return 'Некорректная позиция просмотра';
    }

    final duration =
        durationSec ?? _progress[episodeId]?.durationSec;

    final position = duration != null && duration > 0
        ? positionSec.clamp(0, duration).toInt()
        : positionSec;

    final sessionVersion = _sessionVersion;
    final saveVersion = (_saveVersions[episodeId] ?? 0) + 1;
    _saveVersions[episodeId] = saveVersion;

    final result = await _repository.save(
      WatchProgress(
        episodeId: episodeId,
        positionSec: position,
        durationSec: duration,
      ),
    );

    if (sessionVersion != _sessionVersion) {
      return 'Сессия изменилась — повторите действие';
    }

    if (_saveVersions[episodeId] != saveVersion) {
      return null;
    }

    switch (result) {
      case Ok(:final value):
        _progress[episodeId] = value;
        notifyListeners();
        return null;

      case Err(:final msg):
        return msg;
    }
  }

  void clear() {
    _sessionVersion++;
    _loadVersion++;
    _progress.clear();
    _saveVersions.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}