import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/main_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

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