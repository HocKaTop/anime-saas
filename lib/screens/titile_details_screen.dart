import 'package:flutter/material.dart';
import 'package:animesaas/widgets/episode_card.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../widgets/error_view.dart';
import '../models/episode_model.dart';
import '../router_names.dart';

class TitileDetailsScreen extends StatelessWidget {
  final String slug;

  const TitileDetailsScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final episodeModel = context.watch<EpisodeModel>();
    final anime = catalog.bySlug(slug);

    if (catalog.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (catalog.error != null) {
      return Scaffold(
        body: ErrorView(
          message: catalog.error!,
          onRetry: () => context.read<CatalogModel>().load(),
        ),
      );
    }

    if (anime == null) {
      return const Scaffold(body: Center(child: Text('Тайтл не найден')));
    }

    if (episodeModel.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(anime.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (episodeModel.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(anime.title)),
        body: ErrorView(
          message: episodeModel.error!,
          onRetry: () {
            context.read<EpisodeModel>().load();
          },
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final episodes = episodeModel.forTitle(slug);
    return Scaffold(
      appBar: AppBar(title: Text(anime.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.movie_outlined,
              size: 96,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(anime.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 20),
              const SizedBox(width: 4),
              Text('${anime.rating}'),
              const SizedBox(width: 16),
              Text('${anime.year}'),
              const SizedBox(width: 16),
              Text(anime.genre),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  label: const Text("Смотреть"),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_add_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text("Описание", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(anime.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text("Эпизоды", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...episodes.map(
            (episode) => EpisodeCard(
              number: episode.number,
              title: episode.title,
              duration: episode.duration,
              onTap: () {
                context.pushNamed(
                  RouteNames.watch,
                  pathParameters: {'episodeId': episode.id},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
