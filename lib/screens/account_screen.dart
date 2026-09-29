import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/mock_episode_repository.dart';
import '../repositories/mock_progress_repository.dart';
import '../repositories/mock_title_repository.dart';
import '../repositories/mock_watchlist_repository.dart';
import '../router_names.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _simulateNetworkError = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _simulateNetworkError = context.read<MockTitleRepository>().simulateError;
      _initialized = true;
    }
  }

  void _setNetworkError(bool value) {
    context.read<MockTitleRepository>().simulateError = value;
    context.read<MockEpisodeRepository>().simulateError = value;
    context.read<MockWatchlistRepository>().simulateError = value;
    context.read<MockProgressRepository>().simulateError = value;

    setState(() {
      _simulateNetworkError = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 48,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Гость',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Войдите в аккаунт, что бы синхронизировать просмотр',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.pushNamed(RouteNames.login);
            },
            icon: const Icon(Icons.login),
            label: const Text('Войти'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("История просмтра"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Настройки"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_off_outlined),
                  title: const Text('Симулировать сбой сети'),
                  subtitle: const Text(
                    'Тестовый режим для демонстрации ошибок',
                  ),
                  value: _simulateNetworkError,
                  onChanged: _setNetworkError,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("О приложении"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
