import 'package:flutter/material.dart';

import '../router_names.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/watchlist_model.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/search')) {
      return 1;
    }

    if (location.startsWith('/watchlist')) {
      return 2;
    }

    if (location.startsWith('/account')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed(RouteNames.browse);
              break;
            case 1:
              context.goNamed(RouteNames.search);
              break;
            case 2:
              context.goNamed(RouteNames.watchlist);
              break;
            case 3:
              context.goNamed(RouteNames.account);
              break;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),

          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Поиск',
          ),

          NavigationDestination(
            icon: _WatchlistIcon(selected: false),
            selectedIcon: _WatchlistIcon(selected: true),
            label: 'Мой список',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _WatchlistIcon extends StatelessWidget {
  final bool selected;

  const _WatchlistIcon({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistModel>(
      builder: (context, watchlist, child) {
        return Badge(
          isLabelVisible: watchlist.count > 0,
          label: Text('${watchlist.count}'),
          child: child,
        );
      },
      child: Icon(selected ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}
