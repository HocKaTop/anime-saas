import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/watchlist_model.dart';
import '../models/catalog_model.dart';
import '../widgets/error_view.dart';
import '../models/episode_model.dart';
import '../router_names.dart';
import '../widgets/episode_card.dart';

class TitileDetailsScreen extends StatefulWidget {
  final String slug;

  const TitileDetailsScreen({super.key, required this.slug});

  @override
  State<TitileDetailsScreen> createState() => _TitileDetailsScreenState();
}

class _TitileDetailsScreenState extends State<TitileDetailsScreen> {
  String get slug => widget.slug;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant TitileDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EpisodeModel>().load(titleSlug: widget.slug);
      }
    });
  }

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

    if (episodeModel.isLoading || episodeModel.titleSlug != slug) {
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
            context.read<EpisodeModel>().load(titleSlug: slug);
          },
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final episodes = episodeModel.forTitle(slug);
    final playableEpisodes = episodes
        .where((episode) => episode.canWatch)
        .toList();
    final watchlist = context.watch<WatchlistModel>();

    final isSaved = watchlist.contains(anime.id);

    return Scaffold(
      appBar: AppBar(title: Text(anime.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 320,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: anime.posterUrl == null
                ? Icon(
                    Icons.movie_outlined,
                    size: 96,
                    color: scheme.onPrimaryContainer,
                  )
                : Image.network(
                    anime.posterUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image_outlined,
                      size: 96,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(anime.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text('MAL: ${anime.ratingLabel}'),
              Text(anime.yearLabel),
              Text(anime.genre),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: playableEpisodes.isEmpty
                      ? null
                      : () => context.pushNamed(
                          RouteNames.watch,
                          pathParameters: {
                            'episodeId': playableEpisodes.first.id,
                          },
                        ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Смотреть"),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: watchlist.isLoading
                    ? null
                    : () async {
                        final error = await context
                            .read<WatchlistModel>()
                            .toggle(anime.id);
                        if (!context.mounted) {
                          return;
                        }
                        if (error != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                ),
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
          if (episodes.isEmpty) const Text('Опубликованных серий пока нет'),
          ...episodes.map(
            (episode) => EpisodeCard(
              number: episode.number,
              title: 'Сезон ${episode.seasonNumber} · ${episode.title}',
              duration: episode.canWatch
                  ? episode.duration
                  : '${episode.duration} · Видео пока недоступно',
              onTap: episode.canWatch
                  ? () => context.pushNamed(
                      RouteNames.watch,
                      pathParameters: {'episodeId': episode.id},
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
