import 'package:animesaas/models/catalog_model.dart';
import 'package:animesaas/repositories/mock_title_repository.dart';
import 'package:animesaas/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/episode_model.dart';
import 'repositories/mock_episode_repository.dart';
import 'models/watchlist_model.dart';
import 'repositories/mock_watchlist_repository.dart';

void main() {
  final titleRepository = MockTitleRepository();
  final episodeRepository = MockEpisodeRepository();
  final watchlistRepository = MockWatchlistRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockTitleRepository>.value(value: titleRepository),
        Provider<MockEpisodeRepository>.value(value: episodeRepository),
        Provider<MockWatchlistRepository>.value(value: watchlistRepository),
        ChangeNotifierProvider(
          create: (_) => CatalogModel(titleRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => EpisodeModel(episodeRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistModel(watchlistRepository)..load(),
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
