import 'dart:async';

import 'package:animesaas/models/catalog_model.dart';
import 'package:animesaas/repositories/http_watchlist_repository.dart';
import 'package:animesaas/repositories/watchlist_repository.dart';
import 'package:animesaas/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/http_title_repository.dart';
import 'repositories/title_repository.dart';
import 'models/episode_model.dart';
import 'models/watchlist_model.dart';
import 'models/progress_model.dart';
import 'repositories/http_episode_repository.dart';
import 'repositories/episode_repository.dart';
import 'repositories/http_progress_repository.dart';
import 'repositories/progress_repository.dart';
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
  final loggedIn =
                savedToken != null && savedToken.trim().isNotEmpty;
  initRouter(loggedIn: loggedIn);
late final ProfileModel profileModel;
late final WatchlistModel watchlistModel;
late final ProgressModel progressModel;

final apiClient = ApiClient(
  apiBaseUrl,
  tokens,
  onUnauthorized: () {
    profileModel.clear();
    watchlistModel.clear();
    progressModel.clear();
    router.goNamed(RouteNames.login);
  },
);

final watchlistRepository = HttpWatchlistRepository(apiClient);
watchlistModel = WatchlistModel(watchlistRepository);
final progressRepository = HttpProgressRepository(apiClient);
progressModel = ProgressModel(progressRepository);

final authApi = AuthApi(
  apiBaseUrl,
  tokens,
  client: apiClient,
  onSignedIn:(){
    profileModel.clear();
    watchlistModel.clear();
    progressModel.clear();
    unawaited(watchlistModel.load());
  },
  onSignedOut: (){
    profileModel.clear();
    watchlistModel.clear();
    progressModel.clear();
  },
);

profileModel = ProfileModel(authApi);

  final titleRepository = HttpTitleRepository(apiClient);
  final episodeRepository = HttpEpisodeRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>.value(value: authApi),
        Provider<TitleRepository>.value(value: titleRepository),
        Provider<EpisodeRepository>.value(value: episodeRepository),
        Provider<WatchlistRepository>.value(value: watchlistRepository),
        Provider<ApiClient>.value(value: apiClient),
        Provider<ProgressRepository>.value(value: progressRepository),
        ChangeNotifierProvider(
          create: (_) => CatalogModel(titleRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => EpisodeModel(episodeRepository),
        ),
        ChangeNotifierProvider<WatchlistModel>.value(
          value: watchlistModel,
        ),
        ChangeNotifierProvider<ProgressModel>.value(
          value: progressModel,
        ),
        ChangeNotifierProvider<ProfileModel>.value(
         value: profileModel,
        ),
      ],
      child: const MyApp(),
    ),
  );

  if (loggedIn){
    unawaited(watchlistModel.load());
  }
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
