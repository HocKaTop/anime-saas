import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../models/episode_model.dart';
import '../router_names.dart';
import '../widgets/error_view.dart';
import '../widgets/hls_player.dart';

class WatchScreen extends StatelessWidget {
  const WatchScreen({
    super.key,
    required this.episodeId,
  });

  final String episodeId;

  @override
  Widget build(BuildContext context) {
    final episodeModel = context.watch<EpisodeModel>();
    final catalog = context.watch<CatalogModel>();

    if (episodeModel.isLoading || catalog.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final error = episodeModel.error ?? catalog.error;

    if (error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: error,
          onRetry: () {
            if (episodeModel.error != null) {
              context.read<EpisodeModel>().load();
            }

            if (catalog.error != null) {
              context.read<CatalogModel>().load();
            }
          },
        ),
      );
    }

    final episode = episodeModel.byId(episodeId);

    if (episode == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Эпизод не найден')),
      );
    }

    final anime = catalog.bySlug(episode.titleSlug);

    if (anime == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Тайтл не найден')),
      );
    }

    if (!episode.canWatch) {
      return Scaffold(
        appBar: AppBar(title: Text(anime.title)),
        body: const Center(
          child: Text('Видео этой серии пока недоступно'),
        ),
      );
    }

    final episodes = episodeModel.forTitle(episode.titleSlug);
    final index = episodes.indexWhere(
      (item) => item.id == episodeId,
    );

    final previous = index > 0 ? episodes[index - 1] : null;
    final next = index >= 0 && index < episodes.length - 1
        ? episodes[index + 1]
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(anime.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HlsPlayer(
            key: ValueKey(episode.id),
            episodeId: episode.id,
          ),
          const SizedBox(height: 24),
          Text(
            'Сезон ${episode.seasonNumber} · '
            '${episode.number} серия · ${episode.title}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(episode.duration),
          const SizedBox(height: 16),
          Text(
            episode.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: previous == null || !previous.canWatch
                ? null
                : () => context.pushReplacementNamed(
                      RouteNames.watch,
                      pathParameters: {'episodeId': previous.id},
                    ),
            icon: const Icon(Icons.skip_previous),
            label: const Text('Предыдущая серия'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: next == null || !next.canWatch
                ? null
                : () => context.pushReplacementNamed(
                      RouteNames.watch,
                      pathParameters: {'episodeId': next.id},
                    ),
            icon: const Icon(Icons.skip_next),
            label: const Text('Следующая серия'),
          ),
        ],
      ),
    );
  }
}