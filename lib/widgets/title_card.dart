import 'package:flutter/material.dart';
import '../domain/anime_title.dart';


class TitleCard extends StatelessWidget {
  final AnimeTitle anime;
  final VoidCallback? onTap;

  const TitleCard({
    super.key,
    required this.anime,
    this.onTap

  });


  @override
  Widget build(BuildContext context) {
    final scheme =Theme.of(context).colorScheme;
    
    return  SizedBox(
      width:150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Container(
              height:120,
              width: double.infinity,
              color: scheme.primaryContainer,
              child: anime.posterUrl == null
                  ? Icon(
                    Icons.movie_outlined,
                    size: 64,
                    color: scheme.onPrimaryContainer,
                  )
                  : Image.network(
                    anime.posterUrl!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context,error,stackTrace){
                      return Icon(
                        Icons.broken_image_outlined,
                        size:48,
                        color:scheme.onPrimaryContainer,
                      );
                    },
                  )
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${anime.yearLabel} · ${anime.genre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size:16,
                      ),
                      const  SizedBox(width:4),
                      Text(
                        'MAL :${anime.ratingLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ]
                  )

                ],
              ),
            ),
          ],
        ), 
      ),
      ),
    );
  } 
} 