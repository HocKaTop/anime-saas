import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/playback_api.dart';
import '../data/result.dart';
import '../models/progress_model.dart';
import 'error_view.dart';

class HlsPlayer extends StatefulWidget {
  const HlsPlayer({
    super.key,
    required this.episodeId,
  });

  final String episodeId;

  @override
  State<HlsPlayer> createState() => _HlsPlayerState();
}

class _HlsPlayerState extends State<HlsPlayer>
    with WidgetsBindingObserver {
  late final ApiClient _client;
  late final PlaybackApi _playback;
  late final int _sessionVersion;
  late final ProgressModel _progress;

  final Set<Factory<OneSequenceGestureRecognizer>> _playerGestures = {
    Factory<OneSequenceGestureRecognizer>(
      () => EagerGestureRecognizer(),
    ),
  };

  MethodChannel? _channel;
  Timer? _pollTimer;
  Timer? _startupTimer;

  Future<void> _saveQueue = Future<void>.value();

  Uri? _url;
  String? _sessionToken;
  String? _error;
  String? _saveError;

  int _version = 0;
  int _resumePosition = 0;
  int _positionSec = 0;
  int _durationSec = 0;
  int? _lastSavedPosition;

  bool _opening = false;
  bool _polling = false;
  bool _ready = false;
  bool _playing = false;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();

    _client = context.read<ApiClient>();
    _sessionVersion = _client.tokens.sessionVersion;
    _playback = PlaybackApi(_client);
    _progress = context.read<ProgressModel>();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _supported) {
        unawaited(_open());
      }
    });
  }

  Future<void> _open() async {
    if (_opening ||
        !mounted ||
        _client.tokens.sessionVersion != _sessionVersion) {
      return;
    }

    _opening = true;

    try {
      _pollTimer?.cancel();
      _startupTimer?.cancel();

      await _save();
      await _releaseNative();

      if (!mounted) return;

      setState(() {
        _version++;
        _url = null;
        _error = null;
        _saveError = null;
        _ready = false;
        _playing = false;
      });

      final result = await _playback.getManifest(widget.episodeId);
      if (!mounted ||
          _client.tokens.sessionVersion != _sessionVersion) {
        return;
      }

      final Uri url;

      switch (result) {
        case Ok(:final value):
          url = value;

        case Err(:final msg):
          _showError(msg);
          return;
      }

      await _progress.loadEpisode(widget.episodeId);
      if (!mounted || _client.tokens.sessionVersion != _sessionVersion) return;

      if (_progress.error != null) {
        _showError(_progress.error!);
        return;
      }

      final saved = _progress.byEpisode(widget.episodeId);

      _sessionToken = url.queryParameters['access_token'];
      _resumePosition = saved?.positionSec ?? 0;
      _positionSec = _resumePosition;
      _durationSec = 0;
      _lastSavedPosition = _resumePosition;

      setState(() {
        _url = url;
      });
    } finally {
      _opening = false;
    }
  }

  void _onCreated(int id, int version) {
    final channel = MethodChannel('anime/native_hls/$id');

    if (!mounted || version != _version) {
      unawaited(_closeChannel(channel));
      return;
    }

    _channel = channel;

    _startupTimer = Timer(
      const Duration(seconds: 30),
      () => _showError('Видео загружается слишком долго'),
    );

    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        unawaited(_poll(save: timer.tick % 10 == 0));
      },
    );

    unawaited(_poll());
  }

  Future<void> _poll({bool save = false}) async {
    final channel = _channel;
    if (channel == null || _polling) return;

    _polling = true;

    try {
      if (save && !await _refreshPlaybackToken()) {
      return;
      }
      final state = await channel
          .invokeMapMethod<String, dynamic>('state')
          .timeout(const Duration(seconds: 5));

      if (!mounted || _channel != channel) return;

      if (state != null) {
        _applyState(state);
      }

      if (save) {
        await _save();
      }
    } on MissingPluginException {
      if (mounted && _channel == channel) {
        _showError(
          'Системный плеер не подключён. '
          'Полностью перезапустите приложение',
        );
      }
    } on PlatformException {
      if (mounted && _channel == channel) {
        _showError('Ошибка системного плеера');
      }
    } on TimeoutException {
      if (mounted && _channel == channel) {
        _showError('Системный плеер не отвечает');
      }
    } finally {
      _polling = false;
    }
  }

  void _applyState(Map<String, dynamic> state) {
    final error = state['error'];

    if (error is String) {
      _showError(error);
      return;
    }

    if (state['ready'] != true) return;

    final wasPlaying = _playing;

    _positionSec = (state['positionSec'] as num).toInt();
    _durationSec = (state['durationSec'] as num).toInt();
    _playing = state['playing'] == true;

    if (!_ready) {
      _startupTimer?.cancel();

      setState(() {
        _ready = true;
      });
    }

    if (wasPlaying && !_playing) {
      unawaited(_save());
    }
  }

Future<bool> _refreshPlaybackToken() async {
  final channel = _channel;

  if (channel == null || !_ready) {
    return true;
  }

  final result = await _client.accessToken(
    expectedSession: _sessionVersion,
  );

  if (!mounted ||
      _channel != channel ||
      _client.tokens.sessionVersion != _sessionVersion) {
    return false;
  }

  switch (result) {
    case Err(:final msg):
      setState(() => _saveError = msg);
      return false;

    case Ok(:final value):
      if (value == _sessionToken) {
        return true;
      }

      final current = _url;

      if (current == null) {
        return false;
      }

      final updated = current.replace(
        queryParameters: {
          ...current.queryParameters,
          'access_token': value,
        },
      );

      await channel.invokeMethod<void>(
        'replaceSource',
        {'url': updated.toString()},
      ).timeout(const Duration(seconds: 5));

      if (!mounted || _channel != channel) {
        return false;
      }

      _sessionToken = value;
      _url = updated;

      return true;
  }
}

  Future<void> _save() {
  if (!_ready || _durationSec <= 0) {
    return _saveQueue;
  }

  final episodeId = widget.episodeId;
  final durationSec = _durationSec;
  final positionSec =
      _positionSec.clamp(0, durationSec).toInt();

  _saveQueue = _saveQueue.then((_) async {
    if (_client.tokens.sessionVersion != _sessionVersion) {
      return;
    }

    if (_lastSavedPosition == positionSec) {
      return;
    }

    final error = await _progress.savePosition(
      episodeId,
      positionSec: positionSec,
      durationSec: durationSec,
    );

    if (error == null) {
      _lastSavedPosition = positionSec;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _saveError = error;
    });
  });

  return _saveQueue;
}

  Future<void> _pauseAndSave() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      final state = await channel
          .invokeMapMethod<String, dynamic>('pause')
          .timeout(const Duration(seconds: 5));

      if (mounted && _channel == channel && state != null) {
        _applyState(state);
      }
    } on MissingPluginException {
      // Нативный виджет мог уже закрыться.
    } on PlatformException {
      // Сохраним последнюю известную позицию.
    } on TimeoutException {
      // Сохраним последнюю известную позицию.
    } finally {
      await _save();
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    _pollTimer?.cancel();
    _startupTimer?.cancel();

    setState(() {
      _error = message;
    });
  }

  Future<void> _closeChannel(MethodChannel channel) async {
    try {
      await channel
          .invokeMethod<void>('dispose')
          .timeout(const Duration(seconds: 5));
    } on MissingPluginException {
      // Виджет уже освобождён платформой.
    } on PlatformException {
      // Повторное освобождение не требуется.
    } on TimeoutException {
      // Удаление UiKitView также освобождает нативный плеер.
    }
  }

  Future<void> _releaseNative() async {
    final channel = _channel;
    _channel = null;

    if (channel != null) {
      await _closeChannel(channel);
    }
  }

 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    unawaited(_poll(save: true));
  } else {
    unawaited(_pauseAndSave());
  }
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _pollTimer?.cancel();
    _startupTimer?.cancel();

    unawaited(_save());
    unawaited(_releaseNative());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return const Text('Этот системный плеер доступен на iOS');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: () => unawaited(_open()),
      );
    }

    final url = _url;

    if (url == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final version = _version;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiKitView(
                key: ValueKey(version),
                viewType: 'anime/native_hls',
                layoutDirection: TextDirection.ltr,
                gestureRecognizers: _playerGestures,
                creationParams: {
                  'url': url.toString(),
                  'positionSec': _resumePosition,
                },
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  _onCreated(id, version);
                },
              ),
              if (!_ready)
                const IgnorePointer(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        if (_saveError != null) ...[
          const SizedBox(height: 8),
          Text(
            'Прогресс не сохранён: $_saveError',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
