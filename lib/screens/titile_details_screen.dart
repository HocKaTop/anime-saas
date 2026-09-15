import 'package:flutter/material.dart';
import 'package:animesaas/data/mock_data.dart';
import 'package:animesaas/widgets/episode_card.dart';

import 'watch_screen.dart';

class TitileDetailsScreen extends StatelessWidget {
  final AnimeTitle anime;

  const TitileDetailsScreen({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
              color: scheme.primaryContainer,
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
          ...mockEpisodes.map(
            (episode) => EpisodeCard(
              number: episode.number,
              title: episode.title,
              duration: episode.duration,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WatchScreen(anime: anime, episode: episode),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
