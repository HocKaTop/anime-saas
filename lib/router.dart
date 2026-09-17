import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'data/mock_data.dart';

import 'screens/titile_details_screen.dart';
import 'screens/watch_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/browse',

  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(
          child: child,
        );
      },

      routes: [
        GoRoute(
          path: '/browse',
          builder: (context, state) {
            return const BrowseScreen();
          },
        ),

        GoRoute(
          path: '/search',
          builder: (context, state) {
            return const SearchScreen();
          },
        ),

        GoRoute(
          path: '/watchlist',
          builder: (context, state) {
            return const WatchllistScreen();
          },
        ),

        GoRoute(
          path: '/account',
          builder: (context, state) {
            return const AccountScreen();
          },
        ),
      ],
    ),
    GoRoute(
    path: '/titles/:slug',
    builder: (context, state) {
    final slug = state.pathParameters['slug']!;
    final anime = findTitleBySlug(slug);

    if (anime == null) {
      return const Scaffold(
        body: Center(
          child: Text('Тайтл не найден'),
        ),
      );
    }

    return TitileDetailsScreen(
      anime: anime,
    );
  },
),

GoRoute(
  path: '/watch/:episodeId',
  builder: (context, state) {
    final episodeId = state.pathParameters['episodeId']!;
    final episode = findEpisodeById(episodeId);

    if (episode == null) {
      return const Scaffold(
        body: Center(
          child: Text('Эпизод не найден'),
        ),
      );
    }

    final anime = findTitleBySlug(
      episode.titleSlug,
    );

    if (anime == null) {
      return const Scaffold(
        body: Center(
          child: Text('Тайтл не найден'),
        ),
      );
    }

    return WatchScreen(
      anime: anime,
      episode: episode,
    );
  },
),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
  ],
);