import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import "router_names.dart";

import 'screens/titile_details_screen.dart';
import 'screens/watch_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/browse',

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ошибка")),
      body: const Center(child: Text("Страница не найдена")),
    );
  },

  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },

      routes: [
        GoRoute(
          name: RouteNames.browse,
          path: '/browse',
          builder: (context, state) {
            return const BrowseScreen();
          },
        ),

        GoRoute(
          name: RouteNames.search,
          path: '/search',
          builder: (context, state) {
            return const SearchScreen();
          },
        ),

        GoRoute(
          name: RouteNames.watchlist,
          path: '/watchlist',
          builder: (context, state) {
            return const WatchllistScreen();
          },
        ),

        GoRoute(
          name: RouteNames.account,
          path: '/account',
          builder: (context, state) {
            return const AccountScreen();
          },
        ),
      ],
    ),
    GoRoute(
      name: RouteNames.titleDetails,
      path: '/titles/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return TitileDetailsScreen(slug: slug);
      },
    ),

    GoRoute(
      name: RouteNames.watch,
      path: '/watch/:episodeId',
      builder: (context, state) {
        final episodeId = state.pathParameters['episodeId']!;
        return WatchScreen(episodeId: episodeId);
      },
    ),

    GoRoute(
      name: RouteNames.login,
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      name: RouteNames.register,
      path: '/register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
  ],
);
