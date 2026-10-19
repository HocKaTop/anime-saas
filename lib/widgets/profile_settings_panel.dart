import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/account_api.dart';
import '../data/api_client.dart';
import '../data/result.dart';
import '../models/profile_model.dart';

class ProfileSettingsPanel extends StatefulWidget {
  const ProfileSettingsPanel({
    super.key,
    this.nickname,
  });

  final String? nickname;

  @override
  State<ProfileSettingsPanel> createState() =>
      _ProfileSettingsPanelState();
}

class _ProfileSettingsPanelState
    extends State<ProfileSettingsPanel>
    with WidgetsBindingObserver {
  late final ApiClient _client;
  late final AccountApi _api;
  late final int _sessionVersion;

  MalConnection? _mal;
  String? _malError;

  bool _malLoading = false;
  bool _malBusy = false;
  bool _waitingForMal = false;

  int _malRevision = 0;

  bool get _active =>
      mounted &&
      _client.tokens.sessionVersion == _sessionVersion;

  @override
  void initState() {
    super.initState();

    _client = context.read<ApiClient>();
    _api = AccountApi(_client);
    _sessionVersion = _client.tokens.sessionVersion;

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_active) {
        _loadMal();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _waitingForMal &&
        _active) {
      _waitingForMal = false;
      _loadMal();
    }
  }

  void _message(String text) {
    if (!_active) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _loadMal() async {
    if (!_active) return;

    final revision = ++_malRevision;

    setState(() {
      _malLoading = true;
      _malError = null;
    });

    final result = await _api.malStatus();

    if (!_active || revision != _malRevision) {
      return;
    }

    setState(() {
      switch (result) {
        case Ok(:final value):
          _mal = value;

        case Err(:final msg):
          _malError = msg;
      }

      _malLoading = false;
    });
  }

  Future<String?> _submitEdit(
    bool password,
    String first,
    String second,
  ) async {
    if (!_active) {
      return 'Сессия изменилась';
    }

    if (password) {
      final result = await _api.changePassword(
        first,
        second,
      );

      if (!_active) {
        return 'Сессия изменилась';
      }

      return switch (result) {
        Ok() => null,
        Err(:final msg) => msg,
      };
    }

    final result = await _api.updateNickname(first);

    if (!_active) {
      return 'Сессия изменилась';
    }

    switch (result) {
      case Ok(:final value):
        context.read<ProfileModel>().setUser(value);
        return null;

      case Err(:final msg):
        return msg;
    }
  }

  Future<void> _edit({required bool password}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProfileEditDialog(
        password: password,
        nickname: widget.nickname,
        onSave: (first, second) {
          return _submitEdit(password, first, second);
        },
      ),
    );

    if (saved == true) {
      _message(
        password ? 'Пароль изменён' : 'Ник сохранён',
      );
    }
  }

  Future<void> _connectMal() async {
    if (!_active || _malBusy || _malLoading) return;

    setState(() => _malBusy = true);

    try {
      final result = await _api.connectMal();

      if (!_active) return;

      switch (result) {
        case Err(:final msg):
          _message(msg);

        case Ok(:final value):
          _waitingForMal = true;

          final opened = await launchUrl(
            value,
            mode: LaunchMode.externalApplication,
          );

          if (!opened) {
            _waitingForMal = false;
            _message('Не удалось открыть браузер');
          }
      }
    } on Exception {
      _waitingForMal = false;
      _message('Не удалось открыть авторизацию MAL');
    } finally {
      if (_active) {
        setState(() => _malBusy = false);
      }
    }
  }

  Future<void> _disconnectMal() async {
    if (!_active || _malBusy || _malLoading) return;

    setState(() => _malBusy = true);

    try {
      final result = await _api.disconnectMal();

      if (!_active) return;

      switch (result) {
        case Ok():
          _waitingForMal = false;

          setState(() {
            _mal = const MalConnection(connected: false);
            _malError = null;
          });

          _message('MAL отключён');

        case Err(:final msg):
          _message(msg);
      }
    } finally {
      if (_active) {
        setState(() => _malBusy = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mal = _mal;
    final disabled = _malBusy || _malLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Изменить ник'),
          subtitle: Text(widget.nickname ?? 'Ник не задан'),
          onTap: () => _edit(password: false),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Сменить пароль'),
          onTap: () => _edit(password: true),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MyAnimeList',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (disabled)
                  const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  mal == null
                      ? 'Статус подключения пока не получен'
                      : mal.connected
                          ? 'Подключён: ${mal.username ?? 'MAL'}'
                          : 'Аккаунт MAL не подключён',
                ),
                if (mal?.lastSyncAt != null)
                  Text(
                    'Последняя синхронизация: '
                    '${mal!.lastSyncAt!.toLocal().toString().split('.').first}',
                  ),
                if (mal?.lastSyncError != null)
                  Text(mal!.lastSyncError!),
                if (_malError != null)
                  Text(
                    _malError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 8),
                if (mal != null)
                  OutlinedButton(
                    onPressed: disabled
                        ? null
                        : mal.connected
                            ? _disconnectMal
                            : _connectMal,
                    child: Text(
                      mal.connected
                          ? 'Отключить MAL'
                          : 'Подключить MAL',
                    ),
                  ),
                TextButton(
                  onPressed: disabled ? null : _loadMal,
                  child: const Text('Обновить статус MAL'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({
    required this.password,
    required this.nickname,
    required this.onSave,
  });

  final bool password;
  final String? nickname;
  final Future<String?> Function(String, String) onSave;

  @override
  State<_ProfileEditDialog> createState() =>
      _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _first;
  final _second = TextEditingController();
  final _repeat = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _first = TextEditingController(
      text: widget.password ? '' : widget.nickname ?? '',
    );
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final error = await widget.onSave(
        _first.text,
        _second.text,
      );

      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = error);
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _error = 'Не удалось сохранить изменения';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _repeat.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: widget.password ? 16:40,
          vertical: 24
        ),
        constraints: widget.password ? const BoxConstraints.tightFor(width:440):null,
        title: Text(
          widget.password ? 'Сменить пароль' : 'Изменить ник',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _first,
                  enabled: !_saving,
                  obscureText: widget.password,
                  autocorrect: false,
                  enableSuggestions: !widget.password,
                  decoration: InputDecoration(
                    labelText: widget.password
                        ? 'Текущий пароль'
                        : 'Ник',
                    helperText: widget.password
                        ? null
                        : 'Пустое поле удалит ник',
                  ),
                  validator: (value) {
                    final text = value ?? '';

                    if (widget.password) {
                      return text.isEmpty || text.length > 128
                          ? 'Введите текущий пароль (до 128 символов)'
                          : null;
                    }

                    final nickname = text.trim();

                    return nickname.isEmpty ||
                            RegExp(r'^[a-zA-Z0-9_]{3,32}$')
                                .hasMatch(nickname)
                        ? null
                        : 'От 3 до 32 символов: A–Z, a–z, 0–9 и _';
                  },
                ),
                if (widget.password) ...[
                  const SizedBox(height: 25,),
                  TextFormField(
                    controller: _second,
                    enabled: !_saving,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Новый пароль',
                    ),
                    validator: (value) {
                      final length = (value ?? '').length;

                      return length < 8 || length > 128
                          ? 'От 8 до 128 символов'
                          : null;
                    },
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _repeat,
                    enabled: !_saving,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Повторите новый пароль',
                    ),
                    validator: (value) {
                      return value != _second.text
                          ? 'Пароли не совпадают'
                          : null;
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 25,),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Сохраняем…' : 'Сохранить',
            ),
          ),
        ],
      ),
    );
  }
}