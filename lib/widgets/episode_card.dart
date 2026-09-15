import 'package:flutter/material.dart';

class EpisodeCard extends StatelessWidget {
  final int number;
  final String title;
  final String duration;
  final VoidCallback? onTap;

  const EpisodeCard({
    super.key,
    required this.number,
    required this.title,
    required this.duration,
    required this.onTap
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text('$number'),
        ),
        title: Text(title),
        subtitle: Text(duration),
        trailing: const Icon(Icons.play_arrow),
      ),
    );
  }
}