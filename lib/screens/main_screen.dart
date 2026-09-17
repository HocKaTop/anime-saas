import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child
  });

  int _getCurrentIndex(BuildContext context){
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/search')){
      return 1;
    }

    if (location.startsWith('/watchlist')){
      return 2;
    }

    if (location.startsWith('/account')){
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
          switch(index){
            case 0:
              context.go('/browse');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/watchlist');
              break;
            case 3:
              context.go('/account');
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
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
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