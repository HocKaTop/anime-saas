import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/result.dart';
import '../domain/episode.dart';
import '../domain/watch_progress.dart';
import '../models/catalog_model.dart';
import '../models/episode_model.dart';
import '../models/progress_model.dart';
import '../repositories/episode_repository.dart';
import '../router_names.dart';

class ContinueWatchingSection extends StatefulWidget {
  const ContinueWatchingSection({super.key});

  @override
  State<ContinueWatchingSection> createState() =>
      _ContinueWatchingSectionState();
}

class _ContinueWatchingSectionState
    extends State<ContinueWatchingSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<ProgressModel>()
            .loadContinueWatching();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProgressModel>();
    final items = model.continueWatching;

    if (!model.isContinueLoading &&
        model.continueError == null &&
        items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Продолжить просмотр',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          if (model.isContinueLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
          if (model.continueError != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.continueError!),
                  TextButton(
                    onPressed: () {
                      model.loadContinueWatching();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          if (items.isNotEmpty)
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final progress = items[index];

                  return _ResumeCard(
                    key: ValueKey(progress.episodeId),
                    progress: progress,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumeCard extends StatefulWidget {
  const _ResumeCard({
    super.key,
    required this.progress,
  });

  final WatchProgress progress;

  @override
  State<_ResumeCard> createState() => _ResumeCardState();
}

class _ResumeCardState extends State<_ResumeCard> {
  late Future<Result<Episode>> _episodeFuture;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _episodeFuture = _fetchEpisode();
  }

  Future<Result<Episode>> _fetchEpisode() {
    return context.read<EpisodeRepository>().fetchById(
          widget.progress.episodeId,
        );
  }

  void _retry() {
    setState(() {
      _episodeFuture = _fetchEpisode();
    });
  }

  Future<void> _open(Episode episode) async {
    if (_opening) return;

    final client = context.read<ApiClient>();
    final sessionVersion = client.tokens.sessionVersion;
    final episodes = context.read<EpisodeModel>();
    final progress = context.read<ProgressModel>();

    setState(() => _opening = true);

    try {
      // WatchScreen использует EpisodeModel:
      // заранее загружаем серии нужного тайтла.
      await episodes.load(titleSlug: episode.titleSlug);

      if (!mounted ||
          client.tokens.sessionVersion != sessionVersion) {
        return;
      }

      final current = episodes.byId(episode.id);

      final error = episodes.error ??
          (current == null
              ? 'Серия больше недоступна'
              : !current.canWatch
                  ? 'Видео этой серии пока недоступно'
                  : null);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      await context.pushNamed(
        RouteNames.watch,
        pathParameters: {'episodeId': episode.id},
      );

      if (!mounted ||
          client.tokens.sessionVersion != sessionVersion) {
        return;
      }

      await progress.loadContinueWatching();
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  String _time(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder =
        (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final progress = widget.progress;

    return SizedBox(
      width: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder<Result<Episode>>(
          future: _episodeFuture,
          builder: (context, snapshot) {
            final result = snapshot.data;

            if (result == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (result case Err(:final msg)) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      msg,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: _retry,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            final episode = (result as Ok<Episode>).value;
            final anime = catalog.bySlug(episode.titleSlug);
            final poster = anime?.posterUrl;

            return InkWell(
              onTap: _opening ? null : () => _open(episode),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 90,
                      width: double.infinity,
                      child: poster == null
                          ? const Icon(
                              Icons.play_circle_outline,
                              size: 48,
                            )
                          : Image.network(
                              poster,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(
                                Icons.movie_outlined,
                                size: 48,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime?.title ?? episode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Сезон ${episode.seasonNumber} · '
                      'Серия ${episode.number}',
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: progress.durationSec == null
                          ? 0
                          : progress.progress,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_time(progress.positionSec)}'
                      '${progress.durationSec == null ? '' : ' / ${_time(progress.durationSec!)}'}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _opening
                          ? 'Открываем…'
                          : 'Продолжить просмотр',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}