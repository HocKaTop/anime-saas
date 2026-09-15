import 'package:flutter/material.dart';

import "package:animesaas/data/mock_data.dart";

class WatchScreen extends StatelessWidget {
  final AnimeTitle anime;
  final Episode episode;

  const WatchScreen({
    super.key,
    required this.anime,
    required this.episode
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar( 
        title: Text (anime.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle,
                  size: 80,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${episode.number} серия · ${episode.title}',
            style: Theme.of(context).textTheme.titleLarge
          ),
          const SizedBox(height: 8),
          Text(
            episode.duration,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            episode.description,
            style: Theme.of(context).textTheme.bodyLarge
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.skip_previous), label: const Text("Предыдущая"),))
          ],),
          const SizedBox(height: 8),
          Expanded(child: FilledButton.icon(onPressed: (){}, icon: const Icon(Icons.skip_next), label: const Text ("Следующая"))),
          const SizedBox(height: 24,),
          Card(
            child: ListTile(
              leading: const Icon(Icons.closed_caption),
              title: const Text("Субтитры"),
              subtitle: const Text("Русские"),
              trailing: const Icon(Icons.chevron_right),
              onTap: (){},
            ),
          ),
          Card(
            child:ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text("Качество"),
              subtitle: const Text("1080p"),
              trailing: const Icon(Icons.chevron_right),
              onTap:(){},
            ),
          ),
        ],
        
      )
    );
  }
}