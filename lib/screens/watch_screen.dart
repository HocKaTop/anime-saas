import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../models/episode_model.dart';
import '../models/progress_model.dart';
import '../router_names.dart';
import '../widgets/error_view.dart';

class WatchScreen extends StatefulWidget {
  final String episodeId;

  const WatchScreen({super.key, required this.episodeId});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  double? _draftProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProgressModel>().loadEpisode(widget.episodeId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant WatchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episodeId != widget.episodeId) {
      _draftProgress = null;
      context.read<ProgressModel>().loadEpisode(widget.episodeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodeModel = context.watch<EpisodeModel>();
    final catalog = context.watch<CatalogModel>();
    final progressModel = context.watch<ProgressModel>();

    if (episodeModel.isLoading || catalog.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final error = episodeModel.error ?? catalog.error;
    if (error != null) {
      return Scaffold(
        body: ErrorView(
          message: error,
          onRetry: () {
            if (episodeModel.error != null) context.read<EpisodeModel>().load();
            if (catalog.error != null) context.read<CatalogModel>().load();
          },
        ),
      );
    }

    if (progressModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (progressModel.error != null) {
      return Scaffold(
        body: ErrorView(
          message: progressModel.error!,
          onRetry: () =>
              context.read<ProgressModel>().loadEpisode(widget.episodeId),
        ),
      );
    }

    final episode = episodeModel.byId(widget.episodeId);
    if (episode == null) {
      return const Scaffold(body: Center(child: Text('Эпизод не найден')));
    }

    final anime = catalog.bySlug(episode.titleSlug);
    if (anime == null) {
      return const Scaffold(body: Center(child: Text('Тайтл не найден')));
    }

    final episodes = episodeModel.forTitle(episode.titleSlug)
      ..sort((a, b) => a.number.compareTo(b.number));
    final currentIndex = episodes.indexWhere(
      (item) => item.id == widget.episodeId,
    );
    final previous = currentIndex > 0 ? episodes[currentIndex - 1] : null;
    final next = currentIndex >= 0 && currentIndex < episodes.length - 1
        ? episodes[currentIndex + 1]
        : null;

    final savedProgress =
        progressModel.byEpisode(widget.episodeId)?.progress ?? 0.0;
    final displayedProgress = _draftProgress ?? savedProgress;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(anime.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.play_circle, size: 80, color: scheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Прогресс просмотра',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Slider(
            value: displayedProgress,
            min: 0,
            max: 1,
            divisions: 20,
            onChanged: (value) {
              setState(() => _draftProgress = value);
            },
            onChangeEnd: (value) async {
              final error = await context.read<ProgressModel>().saveProgress(
                widget.episodeId,
                value,
              );
              if (!context.mounted) return;
              setState(() => _draftProgress = null);
              if (error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
          Text('${(displayedProgress * 100).round()}% просмотрено'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final error = await context.read<ProgressModel>().saveProgress(
                widget.episodeId,
                1.0,
              );
              if (!context.mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Отметить просмотренным'),
          ),
          const SizedBox(height: 20),
          Text(
            '${episode.number} серия · ${episode.title}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(episode.duration, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            episode.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: previous == null
                      ? null
                      : () => context.pushReplacementNamed(
                          RouteNames.watch,
                          pathParameters: {'episodeId': previous.id},
                        ),
                  icon: const Icon(Icons.skip_previous),
                  label: const Text("Предыдущая"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: next == null
                      ? null
                      : () => context.pushReplacementNamed(
                          RouteNames.watch,
                          pathParameters: {'episodeId': next.id},
                        ),
                  icon: const Icon(Icons.skip_next),
                  label: const Text("Следующая"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.closed_caption),
              title: const Text("Субтитры"),
              subtitle: const Text("Русские"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text("Качество"),
              subtitle: const Text("1080p"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
