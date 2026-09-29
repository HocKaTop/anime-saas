import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../models/watchlist_model.dart';
import '../router_names.dart';
import '../widgets/error_view.dart';
import '../widgets/title_card.dart';

class WatchllistScreen extends StatelessWidget {
  const WatchllistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final watchlist = context.watch<WatchlistModel>();

    Widget body;
    if (catalog.isLoading || watchlist.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (catalog.error != null || watchlist.error != null) {
      body = ErrorView(
        message: catalog.error ?? watchlist.error!,
        onRetry: () {
          if (catalog.error != null) context.read<CatalogModel>().load();
          if (watchlist.error != null) context.read<WatchlistModel>().load();
        },
      );
    } else {
      final titles = catalog.titles
          .where((title) => watchlist.contains(title.id))
          .toList();

      if (titles.isEmpty) {
        body = const Center(child: Text('Список просмотра пуст'));
      } else {
        body = GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: titles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            final anime = titles[index];
            return TitleCard(
              anime: anime,
              onTap: () {
                context.pushNamed(
                  RouteNames.titleDetails,
                  pathParameters: {'slug': anime.slug},
                );
              },
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мой список')),
      body: body,
    );
  }
}
