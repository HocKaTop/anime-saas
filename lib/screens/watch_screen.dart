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
  bool _savingProgress = false;

  @override
  void initState() {
    super.initState();
    _scheduleProgressLoad();
  }

  @override
  void didUpdateWidget(covariant WatchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episodeId != widget.episodeId) {
      _draftProgress = null;
      _savingProgress = false;
      _scheduleProgressLoad();
    }
  }

  void _scheduleProgressLoad() {
    final episodeId = widget.episodeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.episodeId == episodeId) {
        context.read<ProgressModel>().loadEpisode(episodeId);
      }
    });
  }

  Future<void> _saveProgress(double value) async {
    if (_savingProgress) return;
    final episodeId = widget.episodeId;
    final progress = context.read<ProgressModel>();

    setState(() {
      _savingProgress = true;
      _draftProgress = value;
    });

    try {
      final error = await progress.saveProgress(episodeId, value);
      if (!mounted || widget.episodeId != episodeId) return;
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    } finally {
      if (mounted && widget.episodeId == episodeId) {
        setState(() {
          _savingProgress = false;
          _draftProgress = null;
        });
      }
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

    if (!episode.canWatch) {
      return Scaffold(
        appBar: AppBar(title: Text(anime.title)),
        body: const Center(child: Text('Видео этой серии пока недоступно')),
      );
    }

    final episodes = episodeModel.forTitle(episode.titleSlug);
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
            onChanged: _savingProgress
                ? null
                : (value) => setState(() => _draftProgress = value),
            onChangeEnd: _savingProgress ? null : _saveProgress,
          ),
          Text('${(displayedProgress * 100).round()}% просмотрено'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _savingProgress ? null : () => _saveProgress(1.0),
            icon: const Icon(Icons.check),
            label: const Text('Отметить просмотренным'),
          ),
          const SizedBox(height: 20),
          Text(
            'Сезон ${episode.seasonNumber} · '
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
                  onPressed: previous == null || !previous.canWatch
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
                  onPressed: next == null || !next.canWatch
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
