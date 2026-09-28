import '../domain/anime_title.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../widgets/error_view.dart';
import '../widgets/title_card.dart';
import '../router_names.dart';

class BrowseScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    return Scaffold(
      appBar: AppBar(title: const Text("Creepy Oleg")),
      body: _buildBody(context, catalog),
    );
  }

  Widget _buildBody(BuildContext context, CatalogModel catalog) {
    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = catalog.error;

    if (error != null) {
      return ErrorView(
        message: error,
        onRetry: () {
          catalog.load();
        },
      );
    }

    final titles = catalog.titles;

    if (titles.isEmpty) {
      return const Center(child: Text('Каталог пока пуст'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildSection(context, title: 'Популярное сейчас', titles: titles),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Новые релизы',
          titles: titles.reversed.toList(),
        ),
        const SizedBox(height: 24),
        _buildSection(context, title: 'Рекомендуем', titles: titles),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<AnimeTitle> titles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: titles.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8);
            },
            itemBuilder: (context, index) {
              return TitleCard(
                anime: titles[index],
                onTap: () {
                  context.pushNamed(
                    RouteNames.titleDetails,
                    pathParameters: {'slug': titles[index].slug},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
