import 'package:animesaas/models/catalog_model.dart';
import 'package:animesaas/repositories/mock_title_repository.dart';
import 'package:animesaas/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/episode_model.dart';
import 'repositories/mock_episode_repository.dart';
import 'models/watchlist_model.dart';
import 'repositories/mock_watchlist_repository.dart';
import 'models/progress_model.dart';
import 'repositories/mock_progress_repository.dart';

import 'data/api_config.dart';
import 'data/auth_api.dart';
import 'data/token_store.dart';
import 'data/api_client.dart';
import 'models/profile_model.dart';
import 'router_names.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokens = TokenStore();
  final savedToken = await tokens.read();

  initRouter(loggedIn: savedToken != null && savedToken.trim().isNotEmpty);
late final ProfileModel profileModel;

final apiClient = ApiClient(
  apiBaseUrl,
  tokens,
  onUnauthorized: () {
    profileModel.clear();
    router.goNamed(RouteNames.login);
  },
);

final authApi = AuthApi(
  apiBaseUrl,
  tokens,
  client: apiClient,
);

profileModel = ProfileModel(authApi);

  final titleRepository = MockTitleRepository();
  final episodeRepository = MockEpisodeRepository();
  final watchlistRepository = MockWatchlistRepository();
  final progressRepository = MockProgressRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>.value(value: authApi),
        Provider<MockTitleRepository>.value(value: titleRepository),
        Provider<MockEpisodeRepository>.value(value: episodeRepository),
        Provider<MockWatchlistRepository>.value(value: watchlistRepository),
        Provider<ApiClient>.value(value: apiClient),
        Provider<MockProgressRepository>.value(value: progressRepository),
        ChangeNotifierProvider(
          create: (_) => CatalogModel(titleRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => EpisodeModel(episodeRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistModel(watchlistRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressModel(progressRepository),
        ),
        ChangeNotifierProvider<ProfileModel>.value(
         value: profileModel,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CreepyOleg',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFCC430C)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
